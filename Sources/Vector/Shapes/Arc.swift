import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func arc(
        position: CGPoint,
        radius: CGFloat,
        width: CGFloat,
        angle: Angle,
        length: Angle,
        cornerRadius: CGFloat = 0.0
    ) -> VectorPath {
        
        let leadingAngle: Angle = angle - length / 2
        let trailingAngle: Angle = angle + length / 2
                
        let outerRadius: CGFloat = radius + width / 2
        let innerRadius: CGFloat = outerRadius - width
        
        if cornerRadius > 0.0 {
            
            let outerPaddingRadius: CGFloat = outerRadius - cornerRadius
            let innerPaddingRadius: CGFloat = innerRadius + cornerRadius

            let outerPaddingAngle: Angle = Angle(radians: Double(cornerRadius / (outerRadius - cornerRadius)))
            let innerPaddingAngle: Angle = Angle(radians: Double(cornerRadius / (innerRadius + cornerRadius)))
            
            let outerLeadingCenter = CGPoint(
                x: position.x + cos(CGFloat(leadingAngle.radians + outerPaddingAngle.radians)) * outerPaddingRadius,
                y: position.y + sin(CGFloat(leadingAngle.radians + outerPaddingAngle.radians)) * outerPaddingRadius)
            let outerTrailingCenter = CGPoint(
                x: position.x + cos(CGFloat(trailingAngle.radians - outerPaddingAngle.radians)) * outerPaddingRadius,
                y: position.y + sin(CGFloat(trailingAngle.radians - outerPaddingAngle.radians)) * outerPaddingRadius)
            let innerLeadingCenter = CGPoint(
                x: position.x + cos(CGFloat(leadingAngle.radians + innerPaddingAngle.radians)) * innerPaddingRadius,
                y: position.y + sin(CGFloat(leadingAngle.radians + innerPaddingAngle.radians)) * innerPaddingRadius)
            let innerTrailingCenter = CGPoint(
                x: position.x + cos(CGFloat(trailingAngle.radians - innerPaddingAngle.radians)) * innerPaddingRadius,
                y: position.y + sin(CGFloat(trailingAngle.radians - innerPaddingAngle.radians)) * innerPaddingRadius)
            
            let path = Path { path in
                
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
                path.addArc(center: innerTrailingCenter,
                            radius: cornerRadius,
                            startAngle: trailingAngle + Angle(degrees: 90),
                            endAngle: trailingAngle - innerPaddingAngle + Angle(degrees: 180),
                            clockwise: false)
                
                path.addArc(center: position,
                            radius: innerRadius,
                            startAngle: trailingAngle - innerPaddingAngle,
                            endAngle: leadingAngle + innerPaddingAngle,
                            clockwise: true)
                
                path.addArc(center: innerLeadingCenter,
                            radius: cornerRadius,
                            startAngle: leadingAngle + innerPaddingAngle + Angle(degrees: 180),
                            endAngle: leadingAngle + Angle(degrees: 270),
                            clockwise: false)
                path.addArc(center: outerLeadingCenter,
                            radius: cornerRadius,
                            startAngle: leadingAngle + Angle(degrees: 270),
                            endAngle: leadingAngle + outerPaddingAngle,
                            clockwise: false)
                
            }
            
            return VectorPath(cgPath: path.cgPath)
            
        } else {
            
            let path = Path { path in
                
                path.addArc(center: position,
                            radius: outerRadius,
                            startAngle: leadingAngle,
                            endAngle: trailingAngle,
                            clockwise: false)
                
                path.addArc(center: position,
                            radius: innerRadius,
                            startAngle: trailingAngle,
                            endAngle: leadingAngle,
                            clockwise: true)
                
                path.closeSubpath()
            }
            
            return VectorPath(cgPath: path.cgPath)
        }
    }
}
