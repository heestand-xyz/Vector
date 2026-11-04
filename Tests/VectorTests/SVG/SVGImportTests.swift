import CoreGraphics
import Foundation
import Testing
@testable import Vector

struct SVGImportTests {

    @Test("SVGPathExtractor: Compose nested group and path transforms")
    func nestedTransforms() throws {
        let paths: [VectorPath] = try VectorPath.allSVGs(data: document("""
            <g transform="translate(10 20)">
                <g transform="scale(2 3)">
                    <path transform="matrix(1 0 0 1 4 5)" d="M1 2 L3 4"/>
                </g>
            </g>
            """))
        #expect(paths.count == 1)
        let path: VectorPath = try #require(paths.first)
        #expect(path.rawPoints() == [CGPoint(x: 20, y: -41), CGPoint(x: 24, y: -47)])
    }

    @Test("SVGPathExtractor: Parse SVG transform lists in document order", arguments: [
        ("translate(10,20) scale(2)", 12.0, 24.0),
        ("scale(2) translate(10,20)", 22.0, 44.0),
        ("rotate(90)", -2.0, 1.0),
        ("rotate(90,1,1)", 0.0, 1.0),
        ("matrix(2 3 4 5 6 7)", 16.0, 20.0),
        ("translate(1e1,-2E1), scale(.5, 2.)", 10.5, -16.0),
        ("skewX(45)", 3.0, 2.0),
        ("skewY(45)", 1.0, 3.0),
    ])
    func transformLists(transform: String, x: Double, y: Double) throws {
        let path: VectorPath = try .firstSVG(data: document("<path transform=\"\(transform)\" d=\"M1 2 L3 4\"/>"))
        let point: CGPoint = try #require(path.rawPoints().first)
        #expect(abs(point.x - x) < 0.000001)
        #expect(abs(point.y + y) < 0.000001)
    }

    @Test("SVGPathExtractor: Resolve forward and nested uses without rendering definitions")
    func repeatedReferences() throws {
        let paths: [VectorPath] = try VectorPath.allSVGs(data: document("""
            <use href="#group" x="3" y="4" transform="scale(2)"/>
            <defs>
                <g id="group" transform="translate(10 20)">
                    <path id="segment" transform="scale(2)" d="M1 2 L3 4"/>
                </g>
                <path d="M1000 1000 L2000 2000"/>
                <use id="alias" href="#group" x="1"/>
            </defs>
            <g transform="translate(100)"><use xlink:href="#segment"/></g>
            <use href="#alias"/>
            <use href="#segment" xlink:href="#missing"/>
            """))
        try #require(paths.count == 4)
        #expect(paths[0].rawPoints() == [CGPoint(x: 30, y: -56), CGPoint(x: 38, y: -64)])
        #expect(paths[1].rawPoints() == [CGPoint(x: 102, y: -4), CGPoint(x: 106, y: -8)])
        #expect(paths[2].rawPoints() == [CGPoint(x: 13, y: -24), CGPoint(x: 17, y: -28)])
        #expect(paths[3].rawPoints() == [CGPoint(x: 2, y: -4), CGPoint(x: 6, y: -8)])
    }

    @Test("VectorPath: Center a nonzero SVG view box and flip Y once")
    func orientedViewBox() throws {
        let data: Data = document("<path d=\"M10 20 L30 60\"/>", viewBox: "10,20,20,40")
        let (size, paths): (CGSize, [VectorPath]) = try VectorPath.allSVGsWithSize(data: data)
        #expect(size == CGSize(width: 20, height: 40))
        #expect(try #require(paths.first).rawPoints() == [CGPoint(x: 10, y: -20), CGPoint(x: 30, y: -60)])
        let oriented: VectorPath = try .combinedOrientedSVG(data: data)
        #expect(oriented.rawPoints() == [CGPoint(x: -10, y: -20), CGPoint(x: 10, y: 20)])
    }

    @Test("VectorPath: Keep oriented exports inside their view box and round trip asymmetric geometry")
    func orientedExportRoundTrip() throws {
        let path: VectorPath = .line(points: [CGPoint(x: 10, y: 20), CGPoint(x: 30, y: 60), CGPoint(x: 15, y: 50)])
        let data: Data = try path.svgOrientedFileData()
        let raw: VectorPath = try .firstSVG(data: data)
        #expect(raw.boundingBox() == CGRect(x: 0, y: -40, width: 20, height: 40))
        let imported: VectorPath = try .firstOrientedSVG(data: data)
        #expect(imported.rawPoints() == path.translate(x: -20, y: -40).rawPoints())
        #expect(!imported.closed)
    }

    @Test("SVGPathExtractor: Preserve open and closed subpaths through references")
    func subpathClosure() throws {
        let paths: [VectorPath] = try VectorPath.allSVGs(data: document("""
            <defs><path id="mixed" d="M0 0 L1 0 L1 1 Z M2 2 L3 3"/></defs>
            <use href="#mixed" transform="translate(10 20)"/>
            <path d="M4 4 L5 5 Z"/>
            """))
        try #require(paths.count == 2)
        #expect(paths[0].subPaths().map(\.closed) == [true, false])
        #expect(!paths[0].closed)
        #expect(paths[1].closed)
        #expect(!VectorPath.combine(paths: paths).closed)
    }

    @Test("SVGPathExtractor: Reject missing, circular, and unsupported references", arguments: [
        ("<use href=\"#missing\"/>", VectorPath.SVGError.missingReference("#missing")),
        ("<use/>", .missingReference("href")),
        ("<use href=\"other.svg#path\"/>", .unsupportedReference("other.svg#path")),
        ("<use id=\"self\" href=\"#self\"/>", .circularReference("#self")),
        ("<defs><use id=\"a\" href=\"#b\"/><use id=\"b\" href=\"#a\"/></defs><use href=\"#a\"/>", .circularReference("#a")),
        ("<g id=\"parent\"><use href=\"#parent\"/></g>", .circularReference("#parent")),
        ("<defs><symbol id=\"symbol\"><path d=\"M0 0 L1 1\"/></symbol></defs><use href=\"#symbol\"/>", .unsupportedReference("#symbol")),
        ("<path id=\"duplicate\"/><path id=\"duplicate\"/>", .duplicateID("duplicate")),
    ])
    func invalidReferences(body: String, error: VectorPath.SVGError) {
        #expect(throws: error) {
            try VectorPath.allSVGs(data: document(body))
        }
    }

    @Test("SVGPathExtractor: Reject malformed XML and invalid numeric attributes", arguments: [
        "<svg viewBox=\"0 0 100 100\"><path d=\"M0 0 L1 1\"></svg>",
        "<svg viewBox=\"0 0 -100 100\"/>",
        "<svg viewBox=\"0 0 100 100 trailing\"/>",
        "<svg viewBox=\"0 0 100 100\"><g transform=\"translate(1,)\"/></svg>",
        "<svg viewBox=\"0 0 100 100\"><g transform=\"rotate(1,2)\"/></svg>",
        "<svg viewBox=\"0 0 100 100\"><g transform=\"translate(NaN)\"/></svg>",
        "<svg viewBox=\"0 0 100 100\"><g transform=\"scale(1e999)\"/></svg>",
        "<svg viewBox=\"0 0 100 100\"><g transform=\"scale(2) garbage\"/></svg>",
        "<svg viewBox=\"0 0 100 100\"><svg viewBox=\"0 0 10 10\"/></svg>",
    ])
    func invalidDocuments(svg: String) {
        #expect(throws: VectorPath.SVGError.self) {
            try VectorPath.allSVGs(data: Data(svg.utf8))
        }
    }

    private func document(_ body: String, viewBox: String = "0 0 100 100") -> Data {
        Data("<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" viewBox=\"\(viewBox)\">\(body)</svg>".utf8)
    }
}
