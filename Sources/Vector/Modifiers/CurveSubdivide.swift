//
//  CurveSubdivide.swift
//  Vector
//
//  Created by Anton Heestand with AI on 2026-05-14.
//

import CoreGraphics

extension VectorPath {

    public func curveSubdivided(
        subdivisions: Int
    ) -> VectorPath {
        precondition(subdivisions >= 1, "Subdivisions must be at least 1.")

        let subdividedPath = CGMutablePath()
        var subPathStartPoint: CGPoint?
        var currentPoint: CGPoint?

        cgPath.applyWithBlock { elementPointer in
            let element = elementPointer.pointee

            switch element.type {
            case .moveToPoint:
                let point: CGPoint = element.points.pointee
                subdividedPath.move(to: point)
                subPathStartPoint = point
                currentPoint = point

            case .addLineToPoint:
                let point: CGPoint = element.points.pointee
                subdividedPath.addLine(to: point)
                currentPoint = point

            case .addQuadCurveToPoint:
                guard let startPoint: CGPoint = currentPoint else {
                    preconditionFailure("Quadratic curve has no start point.")
                }
                let controlPoint: CGPoint = element.points.advanced(by: 0).pointee
                let endPoint: CGPoint = element.points.advanced(by: 1).pointee
                for index in 1...subdivisions {
                    let t: CGFloat = CGFloat(index) / CGFloat(subdivisions)
                    let point: CGPoint = Self.quadraticBezierPoint(
                        t: t,
                        start: startPoint,
                        controlPoint: controlPoint,
                        end: endPoint
                    )
                    subdividedPath.addLine(to: point)
                }
                currentPoint = endPoint

            case .addCurveToPoint:
                guard let startPoint: CGPoint = currentPoint else {
                    preconditionFailure("Cubic curve has no start point.")
                }
                let controlPoint1: CGPoint = element.points.advanced(by: 0).pointee
                let controlPoint2: CGPoint = element.points.advanced(by: 1).pointee
                let endPoint: CGPoint = element.points.advanced(by: 2).pointee
                for index in 1...subdivisions {
                    let t: CGFloat = CGFloat(index) / CGFloat(subdivisions)
                    let point: CGPoint = Self.cubicBezierPoint(
                        t: t,
                        start: startPoint,
                        controlPoint1: controlPoint1,
                        controlPoint2: controlPoint2,
                        end: endPoint
                    )
                    subdividedPath.addLine(to: point)
                }
                currentPoint = endPoint

            case .closeSubpath:
                guard let subPathStartPoint else {
                    preconditionFailure("Closed subpath has no start point.")
                }
                subdividedPath.closeSubpath()
                currentPoint = subPathStartPoint

            @unknown default:
                preconditionFailure("Unsupported path element.")
            }
        }

        return VectorPath(cgPath: subdividedPath, closed: closed)
    }
}
