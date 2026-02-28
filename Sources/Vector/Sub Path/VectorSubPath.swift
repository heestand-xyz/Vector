//
//  VectorSubPath.swift
//  Vector
//
//  Created by Anton Heestand on 2026-02-28.
//

public struct VectorSubPath {
    public let points: [VectorPoint]
    public let closed: Bool
    public init(points: [VectorPoint], closed: Bool) {
        self.points = points
        self.closed = closed
    }
}
