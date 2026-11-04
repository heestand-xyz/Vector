import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor
import SVGPath

extension VectorPath {
    
    /// Exports an oriented vector into an SVG view box matching the supplied frame.
    public func svgOrientedFileData(
        color: PixelColor = .black,
        backgroundColor: PixelColor = .white,
        lineWidth: CGFloat = 1.0,
        frame: CGRect? = nil
    ) throws -> Data {
        let frame: CGRect = frame ?? boundingBox()
        return try self
            .scale(by: CGSize(width: 1.0, height: -1.0))
            .translate(by: CGPoint(x: -frame.minX, y: frame.minY))
            .svgFileData(color: color, backgroundColor: backgroundColor, lineWidth: lineWidth, size: frame.size)
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
        let (viewBox, vectorPaths): (CGRect, [VectorPath]) = try SVGPathExtractor.extract(data: data)
        return vectorPaths.map { vectorPath in
            vectorPath
                .translate(by: CGPoint(x: -viewBox.midX, y: viewBox.midY))
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
        let (viewBox, vectorPaths): (CGRect, [VectorPath]) = try SVGPathExtractor.extract(data: data)
        return (viewBox.size, vectorPaths)
    }
    
    /// The path inside an svg file.
    public static func svg(
        path: String
    ) throws -> VectorPath {
        
        let cgPath: CGPath = try .from(svgPath: path)
        
        let subPaths: [VectorSubPath] = VectorPath(cgPath: cgPath, closed: false).subPaths()
        return VectorPath(cgPath: cgPath, closed: !subPaths.isEmpty && subPaths.allSatisfy(\.closed))
    }
}
