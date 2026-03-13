//
//  CountPoints.swift
//  Vector
//
//  Created by Anton Heestand on 2026-03-13.
//

import CoreGraphics

extension VectorSubPath {

    var samplingSubPath: VectorSubPath {
        VectorSubPath(points: points, closed: false)
    }

    var leadingAnchorPoint: CGPoint? {
        for vectorPoint in points {
            switch vectorPoint {
            case .point(let point),
                 .curve(let point, _, _):
                return point
            case .quadCurve:
                continue
            }
        }
        return nil
    }

    var trailingAnchorPoint: CGPoint? {
        for vectorPoint in points.reversed() {
            switch vectorPoint {
            case .point(let point),
                 .curve(let point, _, _):
                return point
            case .quadCurve:
                continue
            }
        }
        return nil
    }

    public func points(
        count: Int,
        curveSubdivisions: Int = 20
    ) -> [CGPoint] {
        guard count > 0 else { return [] }

        let openSubPath = samplingSubPath
        guard let leadingPoint: CGPoint = openSubPath.leadingAnchorPoint else { return [] }

        guard count > 1 else { return [leadingPoint] }

        let trailingPoint: CGPoint = openSubPath.trailingAnchorPoint ?? leadingPoint
        let openPath = VectorPath(subPath: openSubPath)
        let totalLength: CGFloat = openPath.length(curveSubdivisions: curveSubdivisions)
        let denominator: CGFloat = CGFloat(count - 1)

        return (0..<count).map { index in
            if index == 0 {
                return leadingPoint
            }
            if index == count - 1 {
                return trailingPoint
            }
            return openPath.point(
                offset: totalLength * (CGFloat(index) / denominator),
                curveSubdivisions: curveSubdivisions
            )
        }
    }
}
