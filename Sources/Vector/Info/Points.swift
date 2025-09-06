//
//  File.swift
//  
//
//  Created by Anton Heestand on 2024-03-02.
//

import CoreGraphics
import SVGPath

extension VectorPath {
    
    public func reversedPoints(
        spacingFraction: CGFloat,
        phaseFraction: CGFloat = 0.0,
        curveSubdivisions: Int = 20
    ) -> [CGPoint] {
        guard spacingFraction > 0.0 else { return [] }
        let spacingFraction: CGFloat = min(max(spacingFraction, 0.0), 1.0)
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let spacing: CGFloat = spacingFraction * totalLength
        let phase: CGFloat = phaseFraction * totalLength
        return reversedPoints(spacing: spacing, phase: phase, curveSubdivisions: curveSubdivisions)
    }
    
    public func reversedPoints(
        spacing: CGFloat,
        phase: CGFloat = 0.0,
        curveSubdivisions: Int = 20
    ) -> [CGPoint] {
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let leftoverLength: CGFloat = totalLength.truncatingRemainder(dividingBy: spacing)
        let points: [CGPoint] = points(spacing: spacing, phase: leftoverLength - phase, curveSubdivisions: curveSubdivisions)
        return points.reversed()
    }
    
    public func points(
        spacingFraction: CGFloat,
        phaseFraction: CGFloat = 0.0,
        curveSubdivisions: Int = 20
    ) -> [CGPoint] {
        guard spacingFraction > 0.0 else { return [] }
        let spacingFraction: CGFloat = min(max(spacingFraction, 0.0), 1.0)
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let spacing: CGFloat = spacingFraction * totalLength
        let phase: CGFloat = phaseFraction * totalLength
        return points(spacing: spacing, phase: phase, curveSubdivisions: curveSubdivisions)
    }
    
    public func points(
        spacing: CGFloat,
        phase: CGFloat = 0.0,
        curveSubdivisions: Int = 20
    ) -> [CGPoint] {

        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        
        var targetPositions: [CGFloat] = []
        var currentPosition: CGFloat = phase.truncatingRemainder(dividingBy: spacing)
        while currentPosition < totalLength {
            targetPositions.append(currentPosition)
            currentPosition += spacing
        }
        
        var position: CGFloat = 0.0
        
        var startPoint: CGPoint?
        var lastPoint: CGPoint?
        var targetPoints: [CGPoint] = []
        
        cgPath.applyWithBlock { elementPointer in
            
            let element = elementPointer.pointee
            
            switch element.type {
            case .moveToPoint:
                startPoint = element.points.pointee
                lastPoint = startPoint
                if phase == 0.0 {
                    targetPoints.append(startPoint!)
                }
            case .addLineToPoint:
                guard let startPoint: CGPoint = lastPoint else { return }
                let endPoint: CGPoint = element.points.pointee
                let length: CGFloat = Self.distance(from: startPoint, to: endPoint)
                for offset in targetPositions
                    .map({ $0 - position })
                    .filter({ $0 > 0.0 && $0 <= length }) {
                    let targetPoint = Self.point(at: offset, from: startPoint, to: endPoint, length: length)
                    targetPoints.append(targetPoint)
                }
                lastPoint = endPoint
                position += length
            case .addQuadCurveToPoint:
                guard let startPoint: CGPoint = lastPoint else { return }
                let controlPoint: CGPoint = element.points.advanced(by: 0).pointee
                let endPoint: CGPoint = element.points.advanced(by: 1).pointee
                let length: CGFloat = Self.curveLength(from: startPoint, to: endPoint, with: controlPoint, subdivisions: curveSubdivisions)
                for offset in targetPositions
                    .map({ $0 - position })
                    .filter({ $0 > 0.0 && $0 <= length }) {
                    let targetPoint = Self.curvePoint(at: offset, from: startPoint, to: endPoint, with: controlPoint, length: length, subdivisions: curveSubdivisions)
                    targetPoints.append(targetPoint)
                }
                lastPoint = endPoint
                position += length
            case .addCurveToPoint:
                guard let startPoint: CGPoint = lastPoint else { return }
                let controlPoint1: CGPoint = element.points.advanced(by: 0).pointee
                let controlPoint2: CGPoint = element.points.advanced(by: 1).pointee
                let endPoint = element.points.advanced(by: 2).pointee
                let length: CGFloat = Self.curveLength(from: startPoint, to: endPoint, with: controlPoint1, and: controlPoint2, subdivisions: curveSubdivisions)
                for offset in targetPositions
                    .map({ $0 - position })
                    .filter({ $0 > 0.0 && $0 <= length }) {
                    let targetPoint = Self.curvePoint(at: offset, from: startPoint, to: endPoint, with: controlPoint1, and: controlPoint2, length: length, subdivisions: curveSubdivisions)
                    targetPoints.append(targetPoint)
                }
                lastPoint = endPoint
                position += length
            case .closeSubpath:
                if let lastPoint, let startPoint {
                    let length = Self.distance(from: lastPoint, to: startPoint)
                    for offset in targetPositions
                        .map({ $0 - position })
                        .filter({ $0 > 0.0 && $0 <= length }) {
                        let targetPoint = Self.point(at: offset, from: lastPoint, to: startPoint, length: length)
                        targetPoints.append(targetPoint)
                    }
                    if lastPoint == startPoint {
                        targetPoints.removeLast()
                    }
                }
                lastPoint = startPoint
            default:
                break
            }
        }
        
        return targetPoints
    }
    
    /// Points of line segments, ignores curves.
    public func rawPoints() -> [CGPoint] {

        var targetPoints: [CGPoint] = []
        
        cgPath.applyWithBlock { elementPointer in
            
            let element = elementPointer.pointee
            
            switch element.type {
            case .moveToPoint:
                targetPoints.append(element.points.pointee)
            case .addLineToPoint:
                targetPoints.append(element.points.pointee)
            case .addQuadCurveToPoint:
                break
            case .addCurveToPoint:
                break
            case .closeSubpath:
                break
            default:
                break
            }
        }
        
        return targetPoints
    }
}
