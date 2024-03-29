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
        spacingFraction: CGFloat,
        phaseFraction: CGFloat = 0.0,
        curveSubdivisions: Int = 20
    ) -> [VectorAnglePoint] {
        guard spacingFraction > 0.0 else { return [] }
        let spacingFraction: CGFloat = min(max(spacingFraction, 0.0), 1.0)
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let spacing: CGFloat = spacingFraction * totalLength
        let phase: CGFloat = phaseFraction * totalLength
        return centeredAnglePoints(spacing: spacing, phase: phase, curveSubdivisions: curveSubdivisions)
    }
    
    public func centeredAnglePoints(
        spacing: CGFloat,
        phase: CGFloat = 0.0,
        curveSubdivisions: Int = 20
    ) -> [VectorAnglePoint] {
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let points: [VectorAnglePoint] = anglePoints(spacing: spacing, phase: totalLength / 2 + phase, curveSubdivisions: curveSubdivisions)
        return points
    }
    
    public func reversedAnglePoints(
        spacingFraction: CGFloat,
        phaseFraction: CGFloat = 0.0,
        curveSubdivisions: Int = 20
    ) -> [VectorAnglePoint] {
        guard spacingFraction > 0.0 else { return [] }
        let spacingFraction: CGFloat = min(max(spacingFraction, 0.0), 1.0)
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let spacing: CGFloat = spacingFraction * totalLength
        let phase: CGFloat = phaseFraction * totalLength
        return reversedAnglePoints(spacing: spacing, phase: phase, curveSubdivisions: curveSubdivisions)
    }
    
    public func reversedAnglePoints(
        spacing: CGFloat,
        phase: CGFloat = 0.0,
        curveSubdivisions: Int = 20
    ) -> [VectorAnglePoint] {
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let leftoverLength: CGFloat = totalLength.truncatingRemainder(dividingBy: spacing)
        let points: [VectorAnglePoint] = anglePoints(spacing: spacing, phase: leftoverLength - phase - 0.0001, curveSubdivisions: curveSubdivisions)
        return points.reversed()
    }
    
    public func anglePoints(
        spacingFraction: CGFloat,
        phaseFraction: CGFloat = 0.0,
        curveSubdivisions: Int = 20
    ) -> [VectorAnglePoint] {
        guard spacingFraction > 0.0 else { return [] }
        let spacingFraction: CGFloat = min(max(spacingFraction, 0.0), 1.0)
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let spacing: CGFloat = spacingFraction * totalLength
        let phase: CGFloat = phaseFraction * totalLength
        return anglePoints(spacing: spacing, phase: phase, curveSubdivisions: curveSubdivisions)
    }
    
    public func anglePoints(
        spacing: CGFloat,
        phase: CGFloat = 0.0,
        curveSubdivisions: Int = 20
    ) -> [VectorAnglePoint] {
        let targetPoints = points(spacing: spacing, phase: phase, curveSubdivisions: curveSubdivisions)
        guard targetPoints.count >= 2 else { return [] }
        return targetPoints.enumerated().map { index, targetPoint in
            if index == 0 {
                let nextPoint: CGPoint = targetPoints[index + 1]
                let angle: Angle = .radians(atan2(nextPoint.y - targetPoint.y, nextPoint.x - targetPoint.x))
                return VectorAnglePoint(point: targetPoint, angle: angle)
            } else if index == targetPoints.count - 1 {
                let prevPoint: CGPoint = targetPoints[index - 1]
                let angle: Angle = .radians(atan2(targetPoint.y - prevPoint.y, targetPoint.x - prevPoint.x))
                return VectorAnglePoint(point: targetPoint, angle: angle)
            } else {
                let prevPoint: CGPoint = targetPoints[index - 1]
                let nextPoint: CGPoint = targetPoints[index + 1]
                let angle: Angle = .radians(atan2(nextPoint.y - prevPoint.y, nextPoint.x - prevPoint.x))
                return VectorAnglePoint(point: targetPoint, angle: angle)
            }
        }
    }
}
