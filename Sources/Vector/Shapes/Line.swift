import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func line(
        points: [CGPoint],
        closed: Bool = false
    ) -> VectorPath {
        
        if points.isEmpty { return .empty }
        
        let cgPath = CGMutablePath()
        cgPath.move(to: points.first!)
        for point in points.dropFirst() {
            cgPath.addLine(to: point)            
        }
        if closed {
            cgPath.closeSubpath()
        }
        
        return VectorPath(cgPath: cgPath, closed: closed)
    }
}
