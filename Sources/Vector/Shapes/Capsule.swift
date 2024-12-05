import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension VectorPath {
    
    public static func capsule(
        position: CGPoint = .zero,
        size: CGSize
    ) -> VectorPath {
        
        let frame = CGRect(center: position, size: size)
        
        let cgPath = CGMutablePath()
        if size.width == size.height {
            cgPath.addEllipse(in: frame)
        } else if size.width > size.height {
            cgPath.addArc(
                center: CGPoint(
                    x: frame.minX + size.height / 2,
                    y: frame.midY
                ),
                radius: size.height / 2,
                startAngle: .pi / 2,
                endAngle: .pi * 1.5,
                clockwise: false
            )
            cgPath.addArc(
                center: CGPoint(
                    x: frame.maxX - size.height / 2,
                    y: frame.midY
                ),
                radius: size.height / 2,
                startAngle: -.pi / 2,
                endAngle: .pi / 2,
                clockwise: false
            )
            cgPath.closeSubpath()
        } else {
            cgPath.addArc(
                center: CGPoint(
                    x: frame.midX,
                    y: frame.minY + size.width / 2
                ),
                radius: size.width / 2,
                startAngle: .pi,
                endAngle: .pi * 2,
                clockwise: false
            )
            cgPath.addArc(
                center: CGPoint(
                    x: frame.midX,
                    y: frame.maxY - size.width / 2
                ),
                radius: size.width / 2,
                startAngle: .zero,
                endAngle: .pi,
                clockwise: false
            )
            cgPath.closeSubpath()
        }
        
        return VectorPath(cgPath: cgPath, closed: true)
    }
}

#Preview {
    VectorPath.capsule(
        size: CGSize(
            width: 200,
            height: 100
        )
    ).path
        .position(x: 100, y: 50)
}
