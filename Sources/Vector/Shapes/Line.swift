import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func line(
        points: [CGPoint]
    ) -> VectorPath {
        
        if points.isEmpty { return .empty }
        
        let cgPath = CGMutablePath()
        cgPath.move(to: points.first!)
        for point in points.dropFirst() {
            cgPath.addLine(to: point)            
        }
        
        return VectorPath(cgPath: cgPath, closed: false)
    }
}
