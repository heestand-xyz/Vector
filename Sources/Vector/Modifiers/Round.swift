import SwiftUI
import CoreGraphics

extension VectorPath {
    
    public func round(
        cornerRadius: CGFloat
    ) -> VectorPath {
        let path: Path = Self.rounded(
            cgPath: cgPath,
            cornerRadius: cornerRadius, 
            closed: closed
        ).path
        return VectorPath(path: path, closed: closed)
    }
}
