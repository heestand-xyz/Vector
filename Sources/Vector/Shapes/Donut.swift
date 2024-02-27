import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func donut(
        position: CGPoint = .zero,
        radii: ClosedRange<CGFloat>
    ) -> VectorPath {
        
        let path = Path { path in
            
            path.addArc(center: position, radius: radii.upperBound, startAngle: .zero, endAngle: Angle(degrees: 360), clockwise: true)
            
            path.addArc(center: position, radius: radii.lowerBound, startAngle: .zero, endAngle: Angle(degrees: 360), clockwise: false)
        }
        
        return VectorPath(path: path, closed: true)
    }
}
