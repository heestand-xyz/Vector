import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func star(
        count: Int,
        position: CGPoint,
        radii: ClosedRange<CGFloat>,
        cornerRadius: CGFloat = 0.0
    ) -> VectorPath {
        
        var path = Path()
                
        if cornerRadius > 0.0 {
            
            let isSubConvex: Bool = {
                let fraction: CGFloat = 1.0 / CGFloat(count)
                let pointA = CGPoint(x: cos(0.0) * radii.upperBound,
                                   y: sin(0.0) * radii.upperBound)
                let pointB = CGPoint(x: cos(fraction * .pi * 2.0) * radii.upperBound,
                                   y: sin(fraction * .pi * 2.0) * radii.upperBound)
                let pointAB: CGPoint = CGPoint(x: (pointA.x + pointB.x) / 2,
                                               y: (pointA.y + pointB.y) / 2)
                let distanceAB: CGFloat = hypot(pointAB.x, pointAB.y)
                return radii.lowerBound > distanceAB
            }()
            
            for i in 0..<count {

                let prevInnerPoint: CGPoint = point(position: position, radius: radii.lowerBound, angle: angle(index: CGFloat(i) - 0.5, count: count))
                let currentOuterPoint: CGPoint = point(position: position, radius: radii.upperBound, angle: angle(index: CGFloat(i), count: count))
                let nextInnerPoint: CGPoint = point(position: position, radius: radii.lowerBound, angle: angle(index: CGFloat(i) + 0.5, count: count))
                let nextOuterPoint: CGPoint = point(position: position, radius: radii.upperBound, angle: angle(index: CGFloat(i) + 1.0, count: count))

                let outerCornerCircle: RoundedCornerCircle = roundedCornerCircle(leading: prevInnerPoint,
                                                                                 center: currentOuterPoint,
                                                                                 trailing: nextInnerPoint,
                                                                                 cornerRadius: cornerRadius)
                
                let innerCornerCircle: RoundedCornerCircle = roundedCornerCircle(leading: currentOuterPoint,
                                                                                 center: nextInnerPoint,
                                                                                 trailing: nextOuterPoint,
                                                                                 cornerRadius: cornerRadius)
                let outerLeadingAngle: Angle = .radians(atan2(
                    outerCornerCircle.leading.y - outerCornerCircle.center.y,
                    outerCornerCircle.leading.x - outerCornerCircle.center.x))
                let outerTrailingAngle: Angle = .radians(atan2(
                    outerCornerCircle.trailing.y - outerCornerCircle.center.y,
                    outerCornerCircle.trailing.x - outerCornerCircle.center.x))

                let innerLeadingAngle: Angle = .radians(atan2(
                    innerCornerCircle.leading.y - innerCornerCircle.center.y,
                    innerCornerCircle.leading.x - innerCornerCircle.center.x))
                let innerTrailingAngle: Angle = .radians(atan2(
                    innerCornerCircle.trailing.y - innerCornerCircle.center.y,
                    innerCornerCircle.trailing.x - innerCornerCircle.center.x))

                path.addArc(center: outerCornerCircle.center,
                            radius: cornerRadius,
                            startAngle: outerLeadingAngle,
                            endAngle: outerTrailingAngle,
                            clockwise: false)

                path.addArc(center: innerCornerCircle.center,
                            radius: cornerRadius,
                            startAngle: innerLeadingAngle,
                            endAngle: innerTrailingAngle,
                            clockwise: !isSubConvex)
                
            }
            
            path.closeSubpath()
            
        } else {
            
            for i in 0..<count {
                
                if i == 0 {
                    let startPoint: CGPoint = point(position: position, radius: radii.lowerBound, angle: angle(index: CGFloat(i) - 0.5, count: count))
                    path.move(to: startPoint)
                }
                
                let outerPoint: CGPoint = point(position: position, radius: radii.upperBound, angle: angle(index: CGFloat(i), count: count))
                path.addLine(to: outerPoint)
                
                let innerPoint: CGPoint = point(position: position, radius: radii.lowerBound, angle: angle(index: CGFloat(i) + 0.5, count: count))
                path.addLine(to: innerPoint)
                
            }
            
            path.closeSubpath()
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
}

