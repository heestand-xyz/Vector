import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func torus(
        position: CGPoint = .zero,
        radius: CGFloat,
        width: CGFloat
    ) -> VectorPath {
        
        let path = Path { path in
            
            path.addArc(center: position, radius: radius, startAngle: .zero, endAngle: Angle(degrees: 360), clockwise: true)
            
            path.addArc(center: position, radius: radius - width, startAngle: .zero, endAngle: Angle(degrees: 360), clockwise: false)
        }
        
        return VectorPath(path: path, closed: true)
    }
}
