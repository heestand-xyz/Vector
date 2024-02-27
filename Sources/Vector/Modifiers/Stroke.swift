import CoreGraphics

extension VectorPath {
    
    public func stroke(
        lineWidth: CGFloat,
        cap: CGLineCap = .butt, 
        join: CGLineJoin = .miter,
        miterLimit: CGFloat = 10.0,
        dashLengths: [CGFloat] = [],
        dashPhase: CGFloat = 0.0
    ) -> VectorPath {
        
        guard var cgPath: CGPath = cgPath.copy() else {
            return .empty
        }
        
        if !dashLengths.isEmpty {
            cgPath = cgPath.copy(dashingWithPhase: dashPhase, lengths: dashLengths)
        }
        cgPath = cgPath.copy(strokingWithWidth: lineWidth, lineCap: cap, lineJoin: join, miterLimit: miterLimit)

        return VectorPath(cgPath: cgPath, closed: true)
    }
}
