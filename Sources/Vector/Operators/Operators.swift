//
//  Operators.swift
//  Vector
//
//  Created by a-heestand on 2025/01/03.
//

extension VectorPath {
    public static func + (lhs: VectorPath, rhs: VectorPath) -> VectorPath {
        .combine(paths: [lhs, rhs])
    }
    public static func += (lhs: inout VectorPath, rhs: VectorPath) {
        lhs = lhs + rhs
    }
}
