import SwiftUI
import CoreGraphics

extension VectorPath {
    
    struct RoundedPath {
        
        let leadingPoint: CGPoint
        let roundedCorners: [RoundedCorner]
        let trailingPoint: CGPoint
        let closed: Bool
        
        var path: Path {
            Path { path in
                if !closed {
                    path.move(to: leadingPoint)
                }
                for roundedCorner in roundedCorners {
                    path.addArc(center: roundedCorner.roundedPoint,
                                radius: roundedCorner.roundedRadius,
                                startAngle: roundedCorner.leadingAngle,
                                endAngle: roundedCorner.trailingAngle,
                                clockwise: roundedCorner.clockwise)
                }
                if closed {
                    path.closeSubpath()
                } else {
                    path.addLine(to: trailingPoint)
                }
            }
        }
        
        func sample(at offset: CGFloat) -> CGPoint {
            .zero
        }
        
        func length() -> CGFloat {
            0.0
        }
    }
    
    static func rounded(cgPath: CGPath, cornerRadius: CGFloat, closed: Bool = true) -> RoundedPath {
        
        var points: [CGPoint] = []
        cgPath.applyWithBlock { element in
            points.append(element.pointee.points.pointee)
        }
        if points.isEmpty {
            return RoundedPath(leadingPoint: .zero,
                               roundedCorners: [],
                               trailingPoint: .zero,
                               closed: closed)
        }
        if points.count < 3 {
            return RoundedPath(leadingPoint: points.first!,
                               roundedCorners: [],
                               trailingPoint: points.last!,
                               closed: closed)
        }
        
        let roundedCorners: [RoundedCorner] = { () -> [RoundedCorner] in
            
            var roundedCorners: [RoundedCorner] = []
            
            for (index, point) in points.enumerated() {
                
                if !closed {
                    guard index > 0, index < points.count - 1 else { continue }
                }
                
                let previousPoint = index == 0 ? points.last! : points[index - 1]
                let nextPoint = index == points.count - 1 ? points.first! : points[index + 1]
                
                let roundedCorner: RoundedCorner = roundedCorner(
                    at: point,
                    from: previousPoint,
                    to: nextPoint, 
                    cornerRadius: cornerRadius
                )
                roundedCorners.append(roundedCorner)
            }
            
            return roundedCorners
        }()
        
        return RoundedPath(leadingPoint: points.first!,
                           roundedCorners: roundedCorners,
                           trailingPoint: points.last!,
                           closed: closed)
    }
}
