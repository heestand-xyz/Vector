//
//  File.swift
//  
//
//  Created by Anton on 2024-03-03.
//

import SwiftUI
import CoreGraphics

extension VectorPath {
    
    public func centeredAnglePoints(
        spacingAsFraction: CGFloat,
        phaseAsFraction: CGFloat = 0.0,
        curveSubdivisions: Int = 10
    ) -> [VectorAnglePoint] {
        guard spacingAsFraction > 0.0 else { return [] }
        let spacingFraction: CGFloat = min(max(spacingAsFraction, 0.0), 1.0)
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let spacing: CGFloat = spacingFraction * totalLength
        let phase: CGFloat = phaseAsFraction * totalLength
        return centeredAnglePoints(spacing: spacing, phase: phase, curveSubdivisions: curveSubdivisions)
    }
    
    public func centeredAnglePoints(
        spacing: CGFloat,
        phase: CGFloat = 0.0,
        curveSubdivisions: Int = 10
    ) -> [VectorAnglePoint] {
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let points: [VectorAnglePoint] = anglePoints(spacing: spacing, phase: totalLength / 2 + phase, curveSubdivisions: curveSubdivisions)
        return points
    }
    
    public func reversedAnglePoints(
        spacingAsFraction: CGFloat,
        phaseAsFraction: CGFloat = 0.0,
        curveSubdivisions: Int = 10
    ) -> [VectorAnglePoint] {
        guard spacingAsFraction > 0.0 else { return [] }
        let spacingFraction: CGFloat = min(max(spacingAsFraction, 0.0), 1.0)
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let spacing: CGFloat = spacingFraction * totalLength
        let phase: CGFloat = phaseAsFraction * totalLength
        return reversedAnglePoints(spacing: spacing, phase: phase, curveSubdivisions: curveSubdivisions)
    }
    
    public func reversedAnglePoints(
        spacing: CGFloat,
        phase: CGFloat = 0.0,
        curveSubdivisions: Int = 10
    ) -> [VectorAnglePoint] {
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let leftoverLength: CGFloat = totalLength.truncatingRemainder(dividingBy: spacing)
        let points: [VectorAnglePoint] = anglePoints(spacing: spacing, phase: leftoverLength - phase - 0.0001, curveSubdivisions: curveSubdivisions)
        return points.reversed()
    }
    
    public func anglePoints(
        spacingAsFraction: CGFloat,
        phaseAsFraction: CGFloat = 0.0,
        curveSubdivisions: Int = 10
    ) -> [VectorAnglePoint] {
        guard spacingAsFraction > 0.0 else { return [] }
        let spacingFraction: CGFloat = min(max(spacingAsFraction, 0.0), 1.0)
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let spacing: CGFloat = spacingFraction * totalLength
        let phase: CGFloat = phaseAsFraction * totalLength
        return anglePoints(spacing: spacing, phase: phase, curveSubdivisions: curveSubdivisions)
    }
    
    public func anglePoints(
        spacing: CGFloat,
        phase: CGFloat = 0.0,
        curveSubdivisions: Int = 10
    ) -> [VectorAnglePoint] {
        let targetPoints = points(spacing: spacing, phase: phase, curveSubdivisions: curveSubdivisions)
        guard targetPoints.count >= 2 else { return [] }
        return targetPoints.enumerated().map { index, targetPoint in
            if index < targetPoints.count - 1 {
                let nextPoint: CGPoint = targetPoints[index + 1]
                let angle: Angle = .radians(atan2(nextPoint.y - targetPoint.y, nextPoint.x - targetPoint.x))
                return VectorAnglePoint(point: targetPoint, angle: angle)
            } else {
                let prevPoint: CGPoint = targetPoints[index - 1]
                let angle: Angle = .radians(atan2(targetPoint.y - prevPoint.y, targetPoint.x - prevPoint.x))
                return VectorAnglePoint(point: targetPoint, angle: angle)
            }
        }
    }
}
