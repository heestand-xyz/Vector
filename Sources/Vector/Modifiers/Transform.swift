import CoreGraphics
import SwiftUI

extension VectorPath {
    
    public func translate(
        by offset: CGPoint
    ) -> VectorPath {
        
        var transform: CGAffineTransform = .identity
            .translatedBy(x: offset.x, y: offset.y)
        
        guard let cgPath: CGPath = cgPath.copy(using: &transform) else {
            return .empty
        }
        
        return VectorPath(cgPath: cgPath)
    }
    
    public func scale(
        by scale: CGFloat
    ) -> VectorPath {
        
        var transform: CGAffineTransform = .identity
            .scaledBy(x: scale, y: scale)
        
        guard let cgPath: CGPath = cgPath.copy(using: &transform) else {
            return .empty
        }
        
        return VectorPath(cgPath: cgPath)
    }
    
    public func scale(
        by size: CGSize
    ) -> VectorPath {
        
        var transform: CGAffineTransform = .identity
            .scaledBy(x: size.width, y: size.height)
        
        guard let cgPath: CGPath = cgPath.copy(using: &transform) else {
            return .empty
        }
        
        return VectorPath(cgPath: cgPath)
    }
    
    public func rotate(
        by rotation: Angle,
        at anchor: CGPoint = .zero
    ) -> VectorPath {
        
        var transform: CGAffineTransform = .identity
            .translatedBy(x: -anchor.x, y: -anchor.y)
            .rotated(by: rotation.radians)
            .translatedBy(x: anchor.x, y: anchor.y)
        
        guard let cgPath: CGPath = cgPath.copy(using: &transform) else {
            return .empty
        }
        
        return VectorPath(cgPath: cgPath)
    }
}
