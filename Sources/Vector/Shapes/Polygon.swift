import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func polygon(
        count: Int,
        position: CGPoint,
        radius: CGFloat,
        cornerRadius: CGFloat = 0.0
    ) -> VectorPath {
       
        let relativeCornerRadius: CGFloat = cornerRadius / maxCornerRadius(count: count, position: position, radius: radius)
        
        return polygon(
            count: count,
            position: position,
            radius: radius,
            relativeCornerRadius: relativeCornerRadius
        )
    }
    
    public static func polygon(
        count: Int,
        position: CGPoint,
        radius: CGFloat,
        relativeCornerRadius: CGFloat
    ) -> VectorPath {
        
        var path = Path()
                
        let maxCornerRadius = maxCornerRadius(count: count, position: position, radius: radius)
        
        if relativeCornerRadius <= 0.0 {
            
            for i in 0..<count {
                
                if i == 0 {
                    let currentPoint: CGPoint = point(position: position, radius: radius, angle: angle(index: CGFloat(i), count: count))
                    path.move(to: currentPoint)
                }
                
                let nextPoint: CGPoint = point(position: position, radius: radius, angle: angle(index: CGFloat(i) + 1.0, count: count))
                path.addLine(to: nextPoint)
                
            }
            
            path.closeSubpath()
            
        } else if relativeCornerRadius < 1.0 {
            
            let cornerRadius: CGFloat = relativeCornerRadius * maxCornerRadius
            
            for i in 0..<count {
                
                let prevPoint: CGPoint = point(position: position, radius: radius, angle: angle(index: CGFloat(i) - 1.0, count: count))
                let currentPoint: CGPoint = point(position: position, radius: radius, angle: angle(index: CGFloat(i), count: count))
                let nextPoint: CGPoint = point(position: position, radius: radius, angle: angle(index: CGFloat(i) + 1.0, count: count))
                
                let cornerCircle: RoundedCornerCircle = roundedCornerCircle(leading: prevPoint,
                                                                            center: currentPoint,
                                                                            trailing: nextPoint,
                                                                            cornerRadius: cornerRadius)
                
                let startAngle = angle(index: CGFloat(i) - 0.5, count: count)
                let startAngleInRadians: Angle = .radians(Double(startAngle) * .pi * 2.0)
                let endAngle = angle(index: CGFloat(i) + 0.5, count: count)
                let endAngleInRadians: Angle = .radians(Double(endAngle) * .pi * 2.0)
                
                path.addArc(center: cornerCircle.center,
                            radius: cornerRadius,
                            startAngle: startAngleInRadians,
                            endAngle: endAngleInRadians,
                            clockwise: false)
                
            }
            
            path.closeSubpath()
            
        } else {
            
            let circleSize = CGSize(width: maxCornerRadius * 2,
                                    height: maxCornerRadius * 2)
            let circleFrame = CGRect(origin: position + maxCornerRadius,
                                     size: circleSize)
            path.addEllipse(in: circleFrame)
        }
        
        return VectorPath(cgPath: path.cgPath)
    }
}

extension VectorPath {
    
    private static func angle(
        index: CGFloat,
        count: Int
    ) -> CGFloat {
        index / CGFloat(count) - 0.25
    }
    
    private static func point(
        position: CGPoint,
        radius: CGFloat,
        angle: CGFloat
    ) -> CGPoint {
        let x: CGFloat = position.x + cos(angle * .pi * 2.0) * radius
        let y: CGFloat = position.y + sin(angle * .pi * 2.0) * radius
        return CGPoint(x: x, y: y)
    }
    
    private static func maxCornerRadius(
        count: Int,
        position: CGPoint,
        radius: CGFloat
    ) -> CGFloat {
        
        let currentPoint: CGPoint = point(position: position, radius: radius, angle: angle(index: 0.0, count: count))
        let nextPoint: CGPoint = point(position: position, radius: radius, angle: angle(index: 1.0, count: count))
        
        let midPoint: CGPoint = CGPoint(x: (currentPoint.x + nextPoint.x) / 2,
                                        y: (currentPoint.y + nextPoint.y) / 2)
        
        let pointDistance: CGPoint = CGPoint(x: abs(midPoint.x - position.x),
                                             y: abs(midPoint.y - position.y))
        let distance: CGFloat = hypot(pointDistance.x, pointDistance.y)
        
        return distance
    }
}
