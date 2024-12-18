import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func circle(
        position: CGPoint = .zero,
        radius: CGFloat
    ) -> VectorPath {
        
        let size = CGSize(width: radius * 2,
                          height: radius * 2)
        let frame = CGRect(center: position, size: size)
        
        let cgPath = CGMutablePath()
        cgPath.addEllipse(in: frame)
        
        return VectorPath(cgPath: cgPath, closed: true)
    }
}
