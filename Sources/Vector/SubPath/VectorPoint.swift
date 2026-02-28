//
//  VectorPoint.swift
//  Vector
//
//  Created by Anton Heestand on 2026-02-28.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

public enum VectorPoint: Sendable, Equatable {
    case point(CGPoint)
    case quadCurve(
        control: CGPoint
    )
    case curvePoint(
        CGPoint,
        leadingControl: CGPoint?,
        trailingControl: CGPoint?
    )
}

extension VectorPoint {
    public static func + (lhs: VectorPoint, rhs: VectorPoint) -> VectorPoint {
        switch (lhs, rhs) {
        case let (.point(lhsPoint), .point(rhsPoint)):
            return .point(lhsPoint + rhsPoint)
        case let (.quadCurve(control: lhsControl), .quadCurve(control: rhsControl)):
            return .quadCurve(control: lhsControl + rhsControl)
        case let (.curvePoint(lhsPoint, leadingControl: lhsLeadingControl, trailingControl: lhsTrailingControl),
                  .curvePoint(rhsPoint, leadingControl: rhsLeadingControl, trailingControl: rhsTrailingControl)):
            return .curvePoint(
                lhsPoint + rhsPoint,
                leadingControl: {
                    guard let lhsLeadingControl else { return nil }
                    guard let rhsLeadingControl else { return nil }
                    return lhsLeadingControl + rhsLeadingControl
                }(),
                trailingControl: {
                    guard let lhsTrailingControl else { return nil }
                    guard let rhsTrailingControl else { return nil }
                    return lhsTrailingControl + rhsTrailingControl
                }()
            )
        default:
            return lhs
        }
    }
}

extension VectorPoint {
    public static func * (lhs: VectorPoint, rhs: Double) -> VectorPoint {
        let scale: CGFloat = CGFloat(rhs)
        return switch lhs {
        case let .point(point):
            .point(point * scale)
        case let .quadCurve(control: control):
            .quadCurve(control: control * scale)
        case let .curvePoint(point, leadingControl: leadingControl, trailingControl: trailingControl):
            .curvePoint(
                point * scale,
                leadingControl: leadingControl.map { $0 * scale },
                trailingControl: trailingControl.map { $0 * scale }
            )
        }
    }
}
