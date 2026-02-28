//
//  VectorSubPath.swift
//  Vector
//
//  Created by Anton Heestand on 2026-02-28.
//

import SwiftUI

public struct VectorSubPath: Sendable {
    public let points: [VectorPoint]
    public let closed: Bool
    public init(points: [VectorPoint], closed: Bool) {
        self.points = points
        self.closed = closed
    }
}

extension VectorSubPath {
    public static func + (lhs: VectorSubPath, rhs: VectorSubPath) -> VectorSubPath {
        guard lhs.closed == rhs.closed else { return lhs }
        guard lhs.points.count == rhs.points.count else { return lhs }
        let points: [VectorPoint] = zip(lhs.points, rhs.points).map { lhsPoint, rhsPoint in
            lhsPoint + rhsPoint
        }
        return VectorSubPath(points: points, closed: lhs.closed)
    }
}

extension VectorSubPath {
    public static func * (lhs: VectorSubPath, rhs: Double) -> VectorSubPath {
        VectorSubPath(
            points: lhs.points.map { point in
                point * rhs
            },
            closed: lhs.closed
        )
    }
}
