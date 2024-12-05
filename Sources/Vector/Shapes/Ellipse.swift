import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func ellipse(
        position: CGPoint = .zero,
        size: CGSize
    ) -> VectorPath {
        
        let frame = CGRect(center: position, size: size)
        
        let cgPath = CGMutablePath()
        cgPath.addEllipse(in: frame)
        
        return VectorPath(cgPath: cgPath, closed: true)
    }
}
