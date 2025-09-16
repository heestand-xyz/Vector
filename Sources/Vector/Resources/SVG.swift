import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor
import SVGPath

extension VectorPath {
    
    enum SVGError: LocalizedError {
        case stringToDataFailed
        case dataToStringFailed
        case noVectorPathsFound
        case svgViewBoxSizeNotFound
        var errorDescription: String? {
            switch self {
            case .stringToDataFailed:
                "String to data conversion failed."
            case .dataToStringFailed:
                "Data to string conversion failed."
            case .noVectorPathsFound:
                "No vector paths found."
            case .svgViewBoxSizeNotFound:
                "SVG view box size not found."
            }
        }
    }
    
    /// This will scale and orient a vector path with it's center at `.zero` it's height being `1.0`.
    public func svgOrientedFileData(
        color: PixelColor = .black,
        backgroundColor: PixelColor = .white,
        lineWidth: CGFloat = 1.0,
        size: CGSize? = nil
    ) throws -> Data {
        let size: CGSize = size ?? boundingBox().size
        return try self
            .scale(by: CGSize(width: 1.0, height: -1.0))
            .translate(by: CGPoint(x: size.width / 2, y: -size.height / 2))
            .svgFileData(color: color, backgroundColor: backgroundColor, lineWidth: lineWidth, size: size)
    }
    
    public func svgFileData(
        color: PixelColor = .black,
        backgroundColor: PixelColor = .white,
        lineWidth: CGFloat = 1.0,
        size: CGSize? = nil
    ) throws -> Data {
        let size: CGSize = size ?? boundingBox().size
        guard let data: Data = svgFileString(
            color: color,
            backgroundColor: backgroundColor,
            lineWidth: lineWidth,
            size: size
        ).data(using: .utf8) else {
            throw SVGError.stringToDataFailed
        }
        return data
    }
    
    public func svgFileString(
        color: PixelColor = .black,
        backgroundColor: PixelColor = .white,
        lineWidth: CGFloat = 1.0,
        size: CGSize
    ) -> String {
        """
        <svg width="\(size.width)" height="\(size.height)" viewBox="0.0 0.0 \(size.width) \(size.height)" fill="none" style="background-color:#\(backgroundColor.hex)" xmlns="http://www.w3.org/2000/svg">
        <path d="\(svgPath)" stroke="#\(color.hex)" stroke-width="\(lineWidth)"/>
        </svg>
        """
    }
    
    /// The path inside an svg file.
    public var svgPath: String {
        let svgPath = SVGPath(cgPath: cgPath)
        let options = SVGPath.WriteOptions(prettyPrinted: false)
        return svgPath.string(with: options)
    }
    
    public static func firstOrientedSVG(
        data: Data
    ) throws -> VectorPath {
        let vectorPaths: [VectorPath] = try allOrientedSVGs(data: data)
        guard let first: VectorPath = vectorPaths.first else {
            throw SVGError.noVectorPathsFound
        }
        return first
    }
    
    public static func combinedOrientedSVG(
        data: Data
    ) throws -> VectorPath {
        .combine(paths: try allOrientedSVGs(data: data))
    }
    
    public static func allOrientedSVGs(
        data: Data
    ) throws -> [VectorPath] {
        let (size, vectorPaths): (CGSize, [VectorPath]) = try allSVGsWithSize(data: data)
        return vectorPaths.map { vectorPath in
            vectorPath
                .translate(by: CGPoint(x: -size.width / 2, y: size.height / 2))
                .scale(by: CGSize(width: 1.0, height: -1.0))
        }
    }
    
    public static func firstSVG(
        data: Data
    ) throws -> VectorPath {
        let vectorPaths: [VectorPath] = try allSVGs(data: data)
        guard let first: VectorPath = vectorPaths.first else {
            throw SVGError.noVectorPathsFound
        }
        return first
    }
    
    public static func combinedSVG(
        data: Data
    ) throws -> VectorPath {
        .combine(paths: try allSVGs(data: data))
    }
    
    public static func allSVGs(
        data: Data
    ) throws -> [VectorPath] {
        try allSVGsWithSize(data: data).vectorPaths
    }
    
    public static func allSVGsWithSize(
        data: Data
    ) throws -> (size: CGSize, vectorPaths: [VectorPath]) {
        let parser = XMLParser(data: data)
        let delegate = SVGPathExtractor()
        parser.delegate = delegate
        parser.parse()
        guard let size: CGSize = delegate.size else {
            throw SVGError.svgViewBoxSizeNotFound
        }
        var vectorPaths: [VectorPath] = []
        for path in delegate.paths {
            let vectorPath: VectorPath = try svg(path: path)
            vectorPaths.append(vectorPath)
        }
        return (size, vectorPaths)
    }
    
    /// The path inside an svg file.
    public static func svg(
        path: String
    ) throws -> VectorPath {
        
        let cgPath: CGPath = try .from(svgPath: path)
        
        return VectorPath(cgPath: cgPath, closed: true)
    }
}

private class SVGPathExtractor: NSObject, XMLParserDelegate {
    var paths: [String] = []
    var size: CGSize?
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        if elementName.lowercased() == "svg" {
            let viewBox: [Double] = attributeDict["viewBox"]?.split(separator: " ").compactMap(Double.init) ?? []
            if viewBox.count == 4 {
                size = CGSize(width: viewBox[2], height: viewBox[3])
            }
        }
        if elementName.lowercased() == "path",
           let d = attributeDict["d"] {
            paths.append(d)
        }
    }
}
