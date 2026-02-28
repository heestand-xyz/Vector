//
//  VectorPoints.swift
//  Vector
//
//  Created by Anton Heestand on 2026-02-28.
//

import CoreGraphics

extension VectorPath {

    public func vectorPoints() -> [VectorPoint] {

        var vectorPoints: [VectorPoint] = []

        cgPath.applyWithBlock { elementPointer in

            let element = elementPointer.pointee

            switch element.type {
            case .moveToPoint:
                vectorPoints.append(.point(element.points.pointee))
            case .addLineToPoint:
                vectorPoints.append(.point(element.points.pointee))
            case .addQuadCurveToPoint:
                let controlPoint: CGPoint = element.points.advanced(by: 0).pointee
                vectorPoints.append(.quadCurve(control: controlPoint))
                let endPoint: CGPoint = element.points.advanced(by: 1).pointee
                vectorPoints.append(.point(endPoint))
            case .addCurveToPoint:
                let leadingControl: CGPoint = element.points.advanced(by: 0).pointee
                let trailingControl: CGPoint = element.points.advanced(by: 1).pointee
                let point: CGPoint = element.points.advanced(by: 2).pointee
                vectorPoints.append(.curvePoint(point, leadingControl: leadingControl, trailingControl: trailingControl))
            case .closeSubpath:
                break
            @unknown default:
                break
            }
        }

        return vectorPoints
    }
}
