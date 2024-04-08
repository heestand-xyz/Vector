import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import SVGPath

extension VectorPath {
    
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
