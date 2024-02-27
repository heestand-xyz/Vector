import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func pie(
        position: CGPoint,
        radius: CGFloat,
        angle: Angle,
        length: Angle,
        cornerRadius: CGFloat = 0.0
    ) -> VectorPath {
        
        let leadingAngle: Angle = angle - length / 2
        let trailingAngle: Angle = angle + length / 2
        
        if cornerRadius > 0.0 {
            
            let minLength = radius * 2
            let arcLength = length.radians * (minLength / 2)
            print(cornerRadius, arcLength / 2)
            let cornerRadius = min(cornerRadius, (arcLength / 2) * 0.9)
            
            let outerRadius: CGFloat = minLength / 2
            
            let outerPaddingRadius: CGFloat = outerRadius - cornerRadius

            let outerPaddingAngle: Angle = Angle(radians: Double(cornerRadius / (outerRadius - cornerRadius)))
            
            let outerLeadingCenter = CGPoint(
                x: position.x + cos(CGFloat(leadingAngle.radians + outerPaddingAngle.radians)) * outerPaddingRadius,
                y: position.y + sin(CGFloat(leadingAngle.radians + outerPaddingAngle.radians)) * outerPaddingRadius)
            let outerTrailingCenter = CGPoint(
                x: position.x + cos(CGFloat(trailingAngle.radians - outerPaddingAngle.radians)) * outerPaddingRadius,
                y: position.y + sin(CGFloat(trailingAngle.radians - outerPaddingAngle.radians)) * outerPaddingRadius)
            
            let innerLeadingSidePoint = CGPoint(
                x: position.x + cos(CGFloat(leadingAngle.radians)) * cornerRadius,
                y: position.y + sin(CGFloat(leadingAngle.radians)) * cornerRadius)
            
            let innerTrailingSidePoint = CGPoint(
                x: position.x + cos(CGFloat(trailingAngle.radians)) * cornerRadius,
                y: position.y + sin(CGFloat(trailingAngle.radians)) * cornerRadius)
            
            let innerTrailingSideExtraPoint = CGPoint(
                x: position.x + cos(CGFloat(trailingAngle.radians)) * (cornerRadius + 1),
                y: position.y + sin(CGFloat(trailingAngle.radians)) * (cornerRadius + 1))
            
            let circle = threePointCircle(innerLeadingSidePoint, innerTrailingSidePoint, innerTrailingSideExtraPoint)

            let path = Path { path in
                
                path.addArc(center: outerLeadingCenter,
                            radius: cornerRadius,
                            startAngle: leadingAngle + Angle(degrees: 270),
                            endAngle: leadingAngle + outerPaddingAngle,
                            clockwise: false)
                
                path.addArc(center: position,
                            radius: outerRadius,
                            startAngle: leadingAngle + outerPaddingAngle,
                            endAngle: trailingAngle - outerPaddingAngle,
                            clockwise: false)
                
                path.addArc(center: outerTrailingCenter,
                            radius: cornerRadius,
                            startAngle: trailingAngle - outerPaddingAngle,
                            endAngle: trailingAngle + Angle(degrees: 90),
                            clockwise: false)
                
                if length != .degrees(180),
                   let circle {
                    let leadingAngle: Angle = .radians(atan2(innerLeadingSidePoint.y - position.y,
                                                             innerLeadingSidePoint.x - position.x))
                    let trailingAngle: Angle = .radians(atan2(innerTrailingSidePoint.y - position.y,
                                                              innerTrailingSidePoint.x - position.x))
                    path.addArc(center: position,
                                radius: circle.radius,
                                startAngle: trailingAngle,
                                endAngle: leadingAngle,
                                clockwise: length.degrees > 180)
                } else {
                    path.addLine(to: position)
                }
                
                path.closeSubpath()
            }
            
            return VectorPath(path: path, closed: true)
            
        } else {
            
            let path = Path { path in
                
                path.move(to: position)
                
                path.addArc(center: position,
                            radius: radius,
                            startAngle: leadingAngle,
                            endAngle: trailingAngle,
                            clockwise: false)
                
                path.closeSubpath()
            }
            
            return VectorPath(path: path, closed: true)
        }
    }
}
