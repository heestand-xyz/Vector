import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func rectangle(
        frame: CGRect,
        cornerRadius: CGFloat = 0.0,
        continuous: Bool = true
    ) -> VectorPath {
        
        if cornerRadius > 0.0 {
            let cgPath = CGMutablePath()
            cgPath.addRect(frame)
            return VectorPath(cgPath: cgPath, closed: true)
        }
        
        let path = Path { path in
            
            let cornerSize = CGSize(
                width: cornerRadius,
                height: cornerRadius
            )
            
            path.addRoundedRect(
                in: frame,
                cornerSize: cornerSize,
                style: continuous ? .continuous : .circular
            )
        }
        return VectorPath(path: path, closed: true)
    }
}
