import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor
import SVGPath

extension VectorPath {
    
    /// This will scale and orient a vector path with it's center at `.zero` it's height being `1.0`.
    public func svgOrientedFileData(
        color: PixelColor = .black,
        backgroundColor: PixelColor = .white,
        lineWidth: CGFloat = 1.0,
        size: CGSize
    ) -> Data {
        self
            .scale(by: size.height)
            .scale(by: CGSize(width: 1.0, height: -1.0))
            .translate(by: CGPoint(x: size.width / 2, y: -size.height / 2))
            .svgFileData(color: color, backgroundColor: backgroundColor, lineWidth: lineWidth, size: size)
    }
    
    public func svgFileData(
        color: PixelColor = .black,
        backgroundColor: PixelColor = .white,
        lineWidth: CGFloat = 1.0,
        size: CGSize
    ) -> Data {
        svgFileString(
            color: color,
            backgroundColor: backgroundColor,
            lineWidth: lineWidth,
            size: size
        ).data(using: .utf8)!
    }
    
    public func svgFileString(
        color: PixelColor = .black,
        backgroundColor: PixelColor = .white,
        lineWidth: CGFloat = 1.0,
        size: CGSize
    ) -> String {
        """
        <svg width="\(size.width)" height="\(size.height)" viewBox="0.0 0.0 \(size.width) \(size.height)" fill="none" style="background-color:#\(backgroundColor.hex)" xmlns="http://www.w3.org/2000/svg">
        <path d="\(svgString)" stroke="#\(color.hex)" stroke-width="\(lineWidth)"/>
        </svg>
        """
    }
    
    public var svgString: String {
        let svgPath = SVGPath(cgPath: cgPath)
        let options = SVGPath.WriteOptions(prettyPrinted: false)
        return svgPath.string(with: options)
    }
    
    public static func svg(
        path: String
    ) throws -> VectorPath {
        
        let cgPath: CGPath = try .from(svgPath: path)
        
        return VectorPath(cgPath: cgPath, closed: true)
    }
}
