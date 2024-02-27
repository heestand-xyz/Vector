import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func area(
        points: [CGPoint]
    ) -> VectorPath {
        
        if points.isEmpty { return .empty }
        
        let cgPath = CGMutablePath()
        cgPath.move(to: points.first!)
        for point in points.dropFirst() {
            cgPath.addLine(to: point)            
        }
        cgPath.closeSubpath()
        
        return VectorPath(cgPath: cgPath, closed: true)
    }
}
