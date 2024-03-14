import CoreGraphics
import SwiftUI

extension VectorPath {
    
    public func stroke(
        lineWidth: CGFloat,
        cap: CGLineCap = .butt, 
        join: CGLineJoin = .miter,
        miterLimit: CGFloat = 10.0,
        dashLengths: [CGFloat] = [],
        dashPhase: CGFloat = 0.0
    ) -> VectorPath {
        
        let style = StrokeStyle(lineWidth: lineWidth, lineCap: cap, lineJoin: join, miterLimit: miterLimit, dash: dashLengths, dashPhase: dashPhase)
        
        return VectorPath(path: path.strokedPath(style), closed: true)
    }
}
