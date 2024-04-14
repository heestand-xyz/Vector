//
//  File.swift
//  
//
//  Created by Anton Heestand on 2024-03-02.
//

import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public func leadingPoint(
        curveSubdivisions: Int = 20
    ) -> CGPoint {
        point(offsetFraction: 0.0,
              curveSubdivisions: curveSubdivisions)
    }
    
    public func trailingPoint(
        curveSubdivisions: Int = 20
    ) -> CGPoint {
        point(offsetFraction: 1.0,
              curveSubdivisions: curveSubdivisions)
    }
    
    public func point(
        offsetFraction: CGFloat,
        curveSubdivisions: Int = 20
    ) -> CGPoint {
        let fraction: CGFloat = min(max(offsetFraction, 0.0), 1.0)
        let length: CGFloat = length(curveSubdivisions: curveSubdivisions)
        let offset: CGFloat = fraction * length
        return point(offset: offset, curveSubdivisions: curveSubdivisions)
    }
    
    public func point(
        offset: CGFloat,
        curveSubdivisions: Int = 20
    ) -> CGPoint {
        
        let totalLength: CGFloat = length(curveSubdivisions: curveSubdivisions)
        var offset: CGFloat = min(max(offset, 0.0), totalLength)
        
        var startPoint: CGPoint?
        var lastPoint: CGPoint?
        var targetPoint: CGPoint?
        
        cgPath.applyWithBlock { elementPointer in
            
            let element = elementPointer.pointee
            
            switch element.type {
            case .moveToPoint:
                guard targetPoint == nil else { return }
                startPoint = element.points.pointee
                lastPoint = startPoint
                if offset == 0.0 {
                    targetPoint = startPoint
                }
            case .addLineToPoint:
                guard targetPoint == nil else { return }
                guard let startPoint: CGPoint = lastPoint else { return }
                let endPoint: CGPoint = element.points.pointee
                let length: CGFloat = Self.distance(from: startPoint, to: endPoint)
                if offset >= 0.0, offset <= length {
                    targetPoint = Self.point(at: offset, from: startPoint, to: endPoint, length: length)
                    return
                }
                lastPoint = endPoint
                offset -= length
            case .addQuadCurveToPoint:
                guard targetPoint == nil else { return }
                guard let startPoint: CGPoint = lastPoint else { return }
                let controlPoint: CGPoint = element.points.advanced(by: 0).pointee
                let endPoint: CGPoint = element.points.advanced(by: 1).pointee
                let length: CGFloat = Self.curveLength(from: startPoint, to: endPoint, with: controlPoint, subdivisions: curveSubdivisions)
                if offset >= 0.0, offset <= length {
                    targetPoint = Self.curvePoint(at: offset, from: startPoint, to: endPoint, with: controlPoint, length: length, subdivisions: curveSubdivisions)
                    return
                }
                lastPoint = endPoint
                offset -= length
            case .addCurveToPoint:
                guard targetPoint == nil else { return }
                guard let startPoint: CGPoint = lastPoint else { return }
                let controlPoint1: CGPoint = element.points.advanced(by: 0).pointee
                let controlPoint2: CGPoint = element.points.advanced(by: 1).pointee
                let endPoint = element.points.advanced(by: 2).pointee
                let length: CGFloat = Self.curveLength(from: startPoint, to: endPoint, with: controlPoint1, and: controlPoint2, subdivisions: curveSubdivisions)
                if offset >= 0.0, offset <= length {
                    targetPoint = Self.curvePoint(at: offset, from: startPoint, to: endPoint, with: controlPoint1, and: controlPoint2, length: length, subdivisions: curveSubdivisions)
                    return
                }
                lastPoint = endPoint
                offset -= length
            case .closeSubpath:
                guard targetPoint == nil else { return }
                if let lastPoint, let startPoint {
                    let length = Self.distance(from: lastPoint, to: startPoint)
                    if offset >= 0.0, offset <= length {
                        targetPoint = Self.point(at: offset, from: lastPoint, to: startPoint, length: length)
                        return
                    }
                }
                lastPoint = startPoint
            default:
                break
            }
        }
        
        return targetPoint ?? lastPoint ?? .zero
    }
}

extension VectorPath {
    
    static func point(at offset: CGFloat, from leadingPoint: CGPoint, to trailingPoint: CGPoint, length: CGFloat) -> CGPoint {
        
        if offset == 0.0 {
            return leadingPoint
        } else if offset == length {
            return trailingPoint
        }

        let fraction: CGFloat = offset / length
        
        return leadingPoint * (1.0 - fraction) + trailingPoint * fraction
    }
    
    static func curvePoint(at offset: CGFloat, from start: CGPoint, to end: CGPoint, with control: CGPoint, length: CGFloat, subdivisions: Int) -> CGPoint {
        
        if offset == 0.0 {
            return start
        } else if offset == length {
            return end
        }
        
        var offset = offset
        var currentPoint = start
        
        for i in 1...subdivisions {
            let t = CGFloat(i) / CGFloat(subdivisions)
            let nextPoint = quadraticBezierPoint(t: t, start: start, controlPoint: control, end: end)
            let subLength: CGFloat = distance(from: currentPoint, to: nextPoint)
            if offset >= 0.0, offset <= subLength {
                return point(at: offset, from: currentPoint, to: nextPoint, length: subLength)
            }
            currentPoint = nextPoint
            offset -= subLength
        }
        
        return end
    }
    
    static func curvePoint(at offset: CGFloat, from start: CGPoint, to end: CGPoint, with control1: CGPoint, and control2: CGPoint, length: CGFloat, subdivisions: Int) -> CGPoint {
        
        if offset == 0.0 {
            return start
        } else if offset == length {
            return end
        }
        
        var offset = offset
        var currentPoint = start
        
        for i in 1...subdivisions {
            let t = CGFloat(i) / CGFloat(subdivisions)
            let nextPoint = cubicBezierPoint(t: t, start: start, controlPoint1: control1, controlPoint2: control2, end: end)
            let subLength: CGFloat = distance(from: currentPoint, to: nextPoint)
            if offset >= 0.0, offset <= subLength {
                return point(at: offset, from: currentPoint, to: nextPoint, length: subLength)
            }
            currentPoint = nextPoint
            offset -= subLength
        }
        
        return end
    }
}
