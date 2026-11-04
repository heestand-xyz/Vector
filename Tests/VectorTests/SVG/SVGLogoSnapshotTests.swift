import Foundation
import Testing
import Vector

struct SVGLogoSnapshotTests {

    @Test("SVGPathExtractor: Render the logo with strokes and resolve all 13 path instances")
    func logoSnapshot() throws {
        let fixtureURL: URL = try #require(Bundle.module.url(forResource: "SVG_Logo", withExtension: "svg"))
        let data: Data = try Data(contentsOf: fixtureURL)
        let vectorPath: VectorPath = try .combinedOrientedSVG(data: data)
        let snapshot: Data = try SVGSnapshotRenderer.png(path: vectorPath.cgPath, dimension: 600, padding: 30)

        // Keep the current output beside the source fixture for visual review.
        // The expected image is separate and is never overwritten by the test.
        #if os(macOS)
        let snapshotURL: URL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("SVG_Logo.current.png")
        try snapshot.write(to: snapshotURL, options: .atomic)
        #endif

        let paths: [VectorPath] = try VectorPath.allOrientedSVGs(data: data)
        #expect(paths.count == 13, "The logo contains two bases, eight bars, and three letters; definitions must only render through references.")

        let expectedURL: URL = try #require(Bundle.module.url(forResource: "SVG_Logo.expected", withExtension: "png"))
        let expected: Data = try Data(contentsOf: expectedURL)
        #expect(try SVGSnapshotRenderer.matches(snapshot, expected), "The stroke rendering differs from SVG_Logo.expected.png; inspect SVG_Logo.current.png before updating the reference.")
    }
}
