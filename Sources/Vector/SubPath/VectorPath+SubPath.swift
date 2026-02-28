//
//  VectorPath+SubPath.swift
//  Vector
//
//  Created by Anton Heestand on 2026-02-28.
//

import SwiftUI
import CoreGraphics

extension VectorPath {

    public init(subPath: VectorSubPath) {
        self.init(subPaths: [subPath])
    }

    public init(subPaths: [VectorSubPath]) {
        let cgPath = CGMutablePath()
        for subPath in subPaths {
            Self.add(subPath: subPath, to: cgPath)
        }
        let closed: Bool = !subPaths.isEmpty && subPaths.allSatisfy(\.closed)
        self.init(cgPath: cgPath, closed: closed)
    }

    private static func add(subPath: VectorSubPath, to cgPath: CGMutablePath) {

        struct Anchor {
            let point: CGPoint
            let trailingControl: CGPoint?
        }

        var hasStartedSubPath: Bool = false
        var currentAnchor: Anchor?
        var pendingQuadControl: CGPoint?

        for vectorPoint in subPath.points {
            switch vectorPoint {
            case .point(let point):
                if !hasStartedSubPath {
                    cgPath.move(to: point)
                    hasStartedSubPath = true
                    currentAnchor = Anchor(point: point, trailingControl: nil)
                    pendingQuadControl = nil
                    continue
                }
                
                if let quadControl: CGPoint = pendingQuadControl {
                    cgPath.addQuadCurve(to: point, control: quadControl)
                    pendingQuadControl = nil
                } else if let trailingControl: CGPoint = currentAnchor?.trailingControl {
                    // Approximate partial cubic handle state as a cubic with mirrored control.
                    cgPath.addCurve(to: point, control1: trailingControl, control2: trailingControl)
                } else {
                    cgPath.addLine(to: point)
                }
                
                currentAnchor = Anchor(point: point, trailingControl: nil)
                
            case .quadCurve(let control):
                pendingQuadControl = control
                
            case .curvePoint(let point, let leadingControl, let trailingControl):
                if !hasStartedSubPath {
                    cgPath.move(to: point)
                    hasStartedSubPath = true
                    currentAnchor = Anchor(point: point, trailingControl: trailingControl)
                    pendingQuadControl = nil
                    continue
                }
                
                if let quadControl: CGPoint = pendingQuadControl {
                    cgPath.addQuadCurve(to: point, control: quadControl)
                    pendingQuadControl = nil
                } else {
                    let previousTrailingControl: CGPoint? = currentAnchor?.trailingControl
                    switch (previousTrailingControl, leadingControl) {
                    case let (control1?, control2?):
                        cgPath.addCurve(to: point, control1: control1, control2: control2)
                    case let (control1?, nil):
                        cgPath.addCurve(to: point, control1: control1, control2: control1)
                    case let (nil, control2?):
                        cgPath.addCurve(to: point, control1: control2, control2: control2)
                    case (nil, nil):
                        cgPath.addLine(to: point)
                    }
                }
                
                currentAnchor = Anchor(point: point, trailingControl: trailingControl)   
            }
        }

        if subPath.closed, hasStartedSubPath {
            cgPath.closeSubpath()
        }
    }
}
