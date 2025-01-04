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
    
    public static func circle(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> VectorPath {
        let position = circleCenter(a, b, c)
        let radius = hypot(position.x - a.x, position.y - a.y)
        return circle(position: position, radius: radius)
    }
    
    public static func circleCenter(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> CGPoint {
        let dya = b.y - a.y
        let dxa = b.x - a.x
        let dyb = c.y - b.y
        let dxb = c.x - b.x
        let sa = dya / dxa
        let sb = dyb / dxb
        let x = (sa * sb * (a.y - c.y) + sb * (a.x + b.x) - sa * (b.x + c.x)) / (2 * (sb - sa))
        let y = -1 * (x - (a.x + b.x) / 2) / sa + (a.y + b.y) / 2
        return CGPoint(x: x, y: y)
    }
}
