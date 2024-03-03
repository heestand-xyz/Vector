//
//  File.swift
//  
//
//  Created by Anton on 2024-03-03.
//

import CoreGraphics
import SwiftUI

public struct VectorAnglePoint: Identifiable {
    public var id: String {
        "\(point.x)_\(point.y)_\(angle.radians)"
    }
    public let point: CGPoint
    public let angle: Angle
    public init(point: CGPoint, angle: Angle) {
        self.point = point
        self.angle = angle
    }
}
