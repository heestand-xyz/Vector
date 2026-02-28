//
//  VectorPoint.swift
//  Vector
//
//  Created by Anton Heestand on 2026-02-28.
//

import SwiftUI
import CoreGraphics

public enum VectorPoint: Sendable {
    case point(CGPoint)
    case quadCurve(
        control: CGPoint
    )
    case curvePoint(
        CGPoint,
        leadingControl: CGPoint?,
        trailingControl: CGPoint?
    )
    case arc(
        center: CGPoint,
        radius: CGFloat,
        startAngle: Angle,
        endAngle: Angle,
        clockwise: Bool
    )
}
