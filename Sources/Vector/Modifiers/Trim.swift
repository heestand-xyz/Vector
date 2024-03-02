import CoreGraphics

extension VectorPath {
    
    public func trim(
        from startFraction: CGFloat = 0.0,
        to endFraction: CGFloat = 1.0
    ) -> VectorPath {
        
        VectorPath(path: path.trimmedPath(from: startFraction, to: endFraction),
                   closed: false)
    }
}
