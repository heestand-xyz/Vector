//
//  VectorSubPaths.swift
//  Vector
//
//  Created by Anton Heestand on 2026-02-28.
//

import CoreGraphics

extension VectorPath {

    public func subPaths() -> [VectorSubPath] {

        let elements: [DecodedCGPathElement] = decodedCGPathElements()
        var subPaths: [VectorSubPath] = []
        var currentSubPathVectorPoints: [VectorPoint] = []
        var currentSubPathClosed: Bool = false
        var currentPoint: CGPoint?
        var subPathStartPoint: CGPoint?

        for index in elements.indices {
            let element: DecodedCGPathElement = elements[index]
            switch element.type {
            case .moveToPoint:
                guard let point: CGPoint = element.points.first else { continue }
                if !currentSubPathVectorPoints.isEmpty {
                    subPaths.append(
                        VectorSubPath(
                            points: currentSubPathVectorPoints,
                            closed: currentSubPathClosed
                        )
                    )
                }
                currentSubPathVectorPoints = []
                currentSubPathClosed = false
                currentPoint = point
                subPathStartPoint = point
                currentSubPathVectorPoints.append(.point(point))
            case .addLineToPoint:
                guard let point: CGPoint = element.points.first else { continue }
                currentPoint = point
                currentSubPathVectorPoints.append(.point(point))
            case .addQuadCurveToPoint:
                guard element.points.count == 2 else { continue }
                let controlPoint: CGPoint = element.points[0]
                currentSubPathVectorPoints.append(.quadCurve(control: controlPoint))
                let endPoint: CGPoint = element.points[1]
                currentPoint = endPoint
                currentSubPathVectorPoints.append(.point(endPoint))
            case .addCurveToPoint:
                guard element.points.count == 3 else { continue }
                guard let startPoint: CGPoint = currentPoint else { continue }

                let segmentTrailingControl: CGPoint = element.points[0]
                let segmentLeadingControl: CGPoint = element.points[1]
                let endPoint: CGPoint = element.points[2]

                let previousIsCurve: Bool = index > 0 && elements[index - 1].type == .addCurveToPoint
                if !previousIsCurve {
                    if let lastVectorPoint: VectorPoint = currentSubPathVectorPoints.last,
                       case let .point(lastPoint) = lastVectorPoint,
                       lastPoint == startPoint {
                        currentSubPathVectorPoints.removeLast()
                    }
                    currentSubPathVectorPoints.append(
                        .curvePoint(
                            startPoint,
                            leadingControl: nil,
                            trailingControl: segmentTrailingControl
                        )
                    )
                }
                
                var trailingControl: CGPoint?
                if index < elements.count - 1 {
                    let nextElement: DecodedCGPathElement = elements[index + 1]
                    if nextElement.type == .addCurveToPoint, nextElement.points.count == 3 {
                        trailingControl = nextElement.points[0]
                    }
                }
                
                currentSubPathVectorPoints.append(
                    .curvePoint(
                        endPoint,
                        leadingControl: segmentLeadingControl,
                        trailingControl: trailingControl
                    )
                )
                currentPoint = endPoint
            case .closeSubpath:
                currentSubPathClosed = true
                currentPoint = subPathStartPoint
            @unknown default:
                break
            }
        }

        if !currentSubPathVectorPoints.isEmpty {
            subPaths.append(
                VectorSubPath(
                    points: currentSubPathVectorPoints,
                    closed: currentSubPathClosed
                )
            )
        }

        return subPaths
    }

    private struct DecodedCGPathElement {
        let type: CGPathElementType
        let points: [CGPoint]
    }

    private func decodedCGPathElements() -> [DecodedCGPathElement] {

        var decodedElements: [DecodedCGPathElement] = []

        cgPath.applyWithBlock { elementPointer in

            let element = elementPointer.pointee

            let pointCount: Int
            switch element.type {
            case .moveToPoint:
                pointCount = 1
            case .addLineToPoint:
                pointCount = 1
            case .addQuadCurveToPoint:
                pointCount = 2
            case .addCurveToPoint:
                pointCount = 3
            case .closeSubpath:
                pointCount = 0
            @unknown default:
                return
            }

            let points: [CGPoint] = (0..<pointCount).map { pointIndex in
                element.points.advanced(by: pointIndex).pointee
            }
            decodedElements.append(DecodedCGPathElement(type: element.type, points: points))
        }

        return decodedElements
    }
}
