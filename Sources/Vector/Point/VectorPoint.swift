//
//  VectorPoint.swift
//  Vector
//
//  Created by Anton Heestand on 2026-02-28.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

public enum VectorPoint: Sendable, Hashable, Codable {
    case point(CGPoint)
    case quadCurve(
        control: CGPoint
    )
    case curve(
        point: CGPoint,
        leadingControl: CGPoint?,
        trailingControl: CGPoint?
    )
}

extension VectorPoint: CustomStringConvertible {
    public var description: String {
        switch self {
        case .point(let point):
            "vectorPoint(.point(x: \(point.x), y: \(point.y)))"
        case .quadCurve(let control):
            "vectorPoint(.quadCurve(controlX: \(control.x), controlY: \(control.y)))"
        case .curve(let point, let leadingControl, let trailingControl):
            "vectorPoint(.curve(x: \(point.x), y: \(point.y), leadingControlX: \(leadingControl?.x, default: "nil"), leadingControlY: \(leadingControl?.y, default: "nil"), trailingControlX: \(trailingControl?.x, default: "nil"), trailingControlY: \(trailingControl?.y, default: "nil")))"
        }
    }
}

extension VectorPoint {
    public static func + (lhs: VectorPoint, rhs: VectorPoint) -> VectorPoint {
        switch (lhs, rhs) {
        case let (.point(lhsPoint), .point(rhsPoint)):
            return .point(lhsPoint + rhsPoint)
        case let (.quadCurve(control: lhsControl), .quadCurve(control: rhsControl)):
            return .quadCurve(control: lhsControl + rhsControl)
        case let (.curve(lhsPoint, leadingControl: lhsLeadingControl, trailingControl: lhsTrailingControl),
                  .curve(rhsPoint, leadingControl: rhsLeadingControl, trailingControl: rhsTrailingControl)):
            return .curve(
                point: lhsPoint + rhsPoint,
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
        case let .curve(point, leadingControl: leadingControl, trailingControl: trailingControl):
            .curve(
                point: point * scale,
                leadingControl: leadingControl.map { $0 * scale },
                trailingControl: trailingControl.map { $0 * scale }
            )
        }
    }
}
