//
//  ArcLine.swift
//  Vector
//
//  Created by a-heestand on 2025/01/04.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func arcLine(
        position: CGPoint = .zero,
        radius: CGFloat,
        angle: Angle,
        length: Angle
    ) -> VectorPath {
        let cgPath = CGMutablePath()
        cgPath.addArc(
            center: position,
            radius: radius,
            startAngle: (angle - length / 2).radians,
            endAngle: (angle + length / 2).radians,
            clockwise: false
        )
        return VectorPath(cgPath: cgPath, closed: false)
    }
    
    public static func arcLine(
        position: CGPoint = .zero,
        radius: CGFloat,
        from leadingAngle: Angle,
        to trailingAngle: Angle,
        clockwise: Bool
    ) -> VectorPath {
        let cgPath = CGMutablePath()
        cgPath.addArc(
            center: position,
            radius: radius,
            startAngle: leadingAngle.radians,
            endAngle: trailingAngle.radians,
            clockwise: clockwise
        )
        return VectorPath(cgPath: cgPath, closed: false)
    }
    
    public static func arcLine(from a: CGPoint, via b: CGPoint, to c: CGPoint, clockwise: Bool) -> VectorPath {
        let position = circleCenter(a, b, c)
        let radius = hypot(position.x - a.x, position.y - a.y)
        let startAngle: Angle = .radians(atan2(a.y - position.y, a.x - position.x))
        let endAngle: Angle = .radians(atan2(c.y - position.y, c.x - position.x))
        return arcLine(position: position, radius: radius, from: startAngle, to: endAngle, clockwise: clockwise)
    }
}
