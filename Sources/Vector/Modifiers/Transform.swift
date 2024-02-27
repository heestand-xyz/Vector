import CoreGraphics
import SwiftUI

extension VectorPath {
    
    public func transform(
        translation: CGPoint,
        scale: CGFloat,
        rotation: Angle,
        anchor: CGPoint = .zero
    ) -> VectorPath {
        
        var transform: CGAffineTransform = .identity
            .translatedBy(x: -anchor.x, y: -anchor.y)
            .rotated(by: rotation.radians)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: anchor.x, y: anchor.y)
            .translatedBy(x: translation.x, y: translation.y)
        
        guard let cgPath: CGPath = cgPath.copy(using: &transform) else {
            return .empty
        }
        
        return VectorPath(cgPath: cgPath, closed: closed)
    }
    
    public func translate(
        by translation: CGPoint
    ) -> VectorPath {
        
        var transform: CGAffineTransform = .identity
            .translatedBy(x: translation.x, y: translation.y)
        
        guard let cgPath: CGPath = cgPath.copy(using: &transform) else {
            return .empty
        }
        
        return VectorPath(cgPath: cgPath, closed: closed)
    }
    
    public func scale(
        by scale: CGFloat
    ) -> VectorPath {
        
        var transform: CGAffineTransform = .identity
            .scaledBy(x: scale, y: scale)
        
        guard let cgPath: CGPath = cgPath.copy(using: &transform) else {
            return .empty
        }
        
        return VectorPath(cgPath: cgPath, closed: closed)
    }
    
    public func scale(
        by size: CGSize
    ) -> VectorPath {
        
        var transform: CGAffineTransform = .identity
            .scaledBy(x: size.width, y: size.height)
        
        guard let cgPath: CGPath = cgPath.copy(using: &transform) else {
            return .empty
        }
        
        return VectorPath(cgPath: cgPath, closed: closed)
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
        
        return VectorPath(cgPath: cgPath, closed: closed)
    }
}
