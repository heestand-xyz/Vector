import SwiftUI
import CoreGraphics

private enum NormalizedSampling {
    case spacing(CGFloat)
    case spacingFraction(CGFloat)
    case count(Int)

    var isValid: Bool {
        switch self {
        case .spacing(let spacing):
            return spacing > 0.0
        case .spacingFraction(let spacingFraction):
            return spacingFraction > 0.0
        case .count(let count):
            return count >= 3
        }
    }

    func points(
        for path: VectorPath,
        curveSubdivisions: Int
    ) -> [CGPoint] {
        switch self {
        case .spacing(let spacing):
            return path.points(
                spacing: spacing,
                curveSubdivisions: curveSubdivisions
            )
        case .spacingFraction(let spacingFraction):
            return path.points(
                spacingFraction: spacingFraction,
                curveSubdivisions: curveSubdivisions
            )
        case .count(let count):
            return path.points(
                spacingFraction: 1.0 / CGFloat(count),
                curveSubdivisions: curveSubdivisions
            )
        }
    }
}

extension VectorPath {
    
    public func normalize(
        spacing: CGFloat,
        curveSubdivisions: Int = 20
    ) -> VectorPath {
        normalize(
            sampling: .spacing(spacing),
            curveSubdivisions: curveSubdivisions
        )
    }
    
    public func normalize(
        spacingFraction: CGFloat,
        curveSubdivisions: Int = 20
    ) -> VectorPath {
        normalize(
            sampling: .spacingFraction(spacingFraction),
            curveSubdivisions: curveSubdivisions
        )
    }
    
    public func normalize(
        count: Int,
        curveSubdivisions: Int = 20
    ) -> VectorPath {
        normalize(
            sampling: .count(count),
            curveSubdivisions: curveSubdivisions
        )
    }
}

private extension VectorPath {

    func normalize(
        sampling: NormalizedSampling,
        curveSubdivisions: Int
    ) -> VectorPath {
        guard sampling.isValid else { return self }

        let originalSubPaths: [VectorSubPath] = subPaths()
        let closedSubPaths: [VectorSubPath] = originalSubPaths.filter(\.closed)
        guard !closedSubPaths.isEmpty else { return self }

        var sampledClosedSubPaths: [VectorSubPath] = []
        sampledClosedSubPaths.reserveCapacity(closedSubPaths.count)

        for closedSubPath in closedSubPaths {
            guard let sampledClosedSubPath: VectorSubPath = Self.sampledClosedSubPath(
                from: closedSubPath,
                sampling: sampling,
                curveSubdivisions: curveSubdivisions
            ) else {
                return self
            }
            sampledClosedSubPaths.append(sampledClosedSubPath)
        }

        let normalizedClosedSubPaths: [VectorSubPath] = Self.normalizedClosedSubPaths(
            from: sampledClosedSubPaths
        )
        guard !normalizedClosedSubPaths.isEmpty else { return self }

        let openSubPaths: [VectorSubPath] = originalSubPaths.filter { !$0.closed }
        return VectorPath(subPaths: normalizedClosedSubPaths + openSubPaths)
    }

    static func sampledClosedSubPath(
        from subPath: VectorSubPath,
        sampling: NormalizedSampling,
        curveSubdivisions: Int
    ) -> VectorSubPath? {
        let path = VectorPath(subPath: subPath)
        let sampledPoints: [CGPoint] = sampling.points(
            for: path,
            curveSubdivisions: curveSubdivisions
        )
        let normalizedPoints: [CGPoint] = normalizeSampledPoints(sampledPoints)
        guard hasEnoughDistinctPoints(normalizedPoints) else { return nil }
        return VectorSubPath(
            points: normalizedPoints.map(VectorPoint.point),
            closed: true
        )
    }

    static func normalizedClosedSubPaths(
        from subPaths: [VectorSubPath]
    ) -> [VectorSubPath] {
        guard !subPaths.isEmpty else { return [] }
        let sampledPath = VectorPath(subPaths: subPaths)
        let normalizedPath = sampledPath.cgPath.union(
            sampledPath.cgPath,
            using: .winding
        )
        return VectorPath(cgPath: normalizedPath, closed: true).subPaths()
    }

    static func normalizeSampledPoints(
        _ points: [CGPoint]
    ) -> [CGPoint] {
        var normalizedPoints: [CGPoint] = []
        normalizedPoints.reserveCapacity(points.count)

        for point in points where normalizedPoints.last != point {
            normalizedPoints.append(point)
        }

        if normalizedPoints.count > 1,
           normalizedPoints.first == normalizedPoints.last {
            normalizedPoints.removeLast()
        }

        return normalizedPoints
    }

    static func hasEnoughDistinctPoints(
        _ points: [CGPoint]
    ) -> Bool {
        guard points.count >= 3 else { return false }
        return Set(points).count >= 3
    }
}
