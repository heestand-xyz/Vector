//
//  File.swift
//  
//
//  Created by Anton on 2024-03-03.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public func anglePoint(
        offsetAsFraction: CGFloat,
        curveSubdivisions: Int = 10
    ) -> VectorAnglePoint {
        let fraction: CGFloat = min(max(offsetAsFraction, 0.0), 1.0)
        let length: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let offset: CGFloat = fraction * length
        return anglePoint(offset: offset, curveSubdivisions: curveSubdivisions)
    }
    
    public func anglePoint(
        offset: CGFloat,
        relativeComparisonOffset: CGFloat = 0.001,
        curveSubdivisions: Int = 10
    ) -> VectorAnglePoint {
        let length: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let targetPoint: CGPoint = point(offset: offset, curveSubdivisions: curveSubdivisions)
        if offset + relativeComparisonOffset < length {
            let nextPoint: CGPoint = point(offset: offset + relativeComparisonOffset, curveSubdivisions: curveSubdivisions)
            let angle: Angle = .radians(atan2(nextPoint.y - targetPoint.y, nextPoint.x - targetPoint.x))
            return VectorAnglePoint(point: targetPoint, angle: angle)
        } else {
            let prevPoint: CGPoint = point(offset: offset - relativeComparisonOffset, curveSubdivisions: curveSubdivisions)
            let angle: Angle = .radians(atan2(targetPoint.y - prevPoint.y, targetPoint.x - prevPoint.x))
            return VectorAnglePoint(point: targetPoint, angle: angle)
        }
    }
}
