import CoreGraphics

extension VectorPath {
    
    struct TreePointCircle {
        let position: CGPoint
        let radius: CGFloat
    }
    
    /// GPT-4
    static func threePointCircle(_ point1: CGPoint, _ point2: CGPoint, _ point3: CGPoint) -> TreePointCircle? {
        
        // Calculate the determinants
        let D = 2 * (point1.x * (point2.y - point3.y) + point2.x * (point3.y - point1.y) + point3.x * (point1.y - point2.y))
        if D == 0 {
            return nil
        }
        
        // Calculate the center (h, k)
        let h = ((point1.x * point1.x + point1.y * point1.y) * (point2.y - point3.y) + (point2.x * point2.x + point2.y * point2.y) * (point3.y - point1.y) + (point3.x * point3.x + point3.y * point3.y) * (point1.y - point2.y)) / D
        let k = ((point1.x * point1.x + point1.y * point1.y) * (point3.x - point2.x) + (point2.x * point2.x + point2.y * point2.y) * (point1.x - point3.x) + (point3.x * point3.x + point3.y * point3.y) * (point2.x - point1.x)) / D
        
        let center = CGPoint(x: h, y: k)
        
        // Calculate the radius r
        let dx = center.x - point1.x
        let dy = center.y - point1.y
        let radius = sqrt(dx * dx + dy * dy)
        
        return TreePointCircle(position: center, radius: radius)
    }
}
