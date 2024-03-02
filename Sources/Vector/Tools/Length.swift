//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2024-03-02.
//

import CoreGraphics

extension VectorPath {
    
    public func length(
        curveSubdivisions: Int = 10
    ) -> CGFloat {
        
        var totalLength: CGFloat = 0.0
        var startPoint: CGPoint?
        var lastPoint: CGPoint?
        
        cgPath.applyWithBlock { elementPointer in
            
            let element = elementPointer.pointee
            
            switch element.type {
            case .moveToPoint:
                startPoint = element.points.pointee
                lastPoint = startPoint
            case .addLineToPoint:
                guard let startPoint: CGPoint = lastPoint else { return }
                let endPoint: CGPoint = element.points.pointee
                totalLength += Self.distance(from: startPoint, to: endPoint)
                lastPoint = endPoint
            case .addQuadCurveToPoint:
                guard let startPoint: CGPoint = lastPoint else { return }
                let controlPoint: CGPoint = element.points.advanced(by: 0).pointee
                let endPoint: CGPoint = element.points.advanced(by: 1).pointee
                totalLength += Self.curveLength(from: startPoint, to: endPoint, with: controlPoint, subdivisions: curveSubdivisions)
                lastPoint = endPoint
            case .addCurveToPoint:
                guard let startPoint: CGPoint = lastPoint else { return }
                let controlPoint1: CGPoint = element.points.advanced(by: 0).pointee
                let controlPoint2: CGPoint = element.points.advanced(by: 1).pointee
                let endPoint = element.points.advanced(by: 2).pointee
                totalLength += Self.curveLength(from: startPoint, to: endPoint, with: controlPoint1, and: controlPoint2, subdivisions: curveSubdivisions)
                lastPoint = endPoint
            case .closeSubpath:
                if let lastPoint, let startPoint {
                    totalLength += Self.distance(from: lastPoint, to: startPoint)
                }
            default:
                break
            }
        }
        
        return totalLength
    }
}

extension VectorPath {
    
    static func distance(from leadingPoint: CGPoint, to trailingPoint: CGPoint) -> CGFloat {
        return hypot(trailingPoint.x - leadingPoint.x, trailingPoint.y - leadingPoint.y)
    }
    
    static func curveLength(from start: CGPoint, to end: CGPoint, with control: CGPoint, subdivisions: Int) -> CGFloat {
        // Approximate length of quadratic Bezier curve
        var length: CGFloat = 0.0
        var prevPoint = start
        
        for i in 1...subdivisions {
            let t = CGFloat(i) / CGFloat(subdivisions)
            let nextPoint = quadraticBezierPoint(t: t, start: start, controlPoint: control, end: end)
            length += distance(from: prevPoint, to: nextPoint)
            prevPoint = nextPoint
        }
        
        return length
    }
    
    static func curveLength(from start: CGPoint, to end: CGPoint, with control1: CGPoint, and control2: CGPoint, subdivisions: Int) -> CGFloat {
        // Approximate length of cubic Bezier curve
        var length: CGFloat = 0.0
        var prevPoint = start
        
        for i in 1...subdivisions {
            let t = CGFloat(i) / CGFloat(subdivisions)
            let nextPoint = cubicBezierPoint(t: t, start: start, controlPoint1: control1, controlPoint2: control2, end: end)
            length += distance(from: prevPoint, to: nextPoint)
            prevPoint = nextPoint
        }
        
        return length
    }
}
