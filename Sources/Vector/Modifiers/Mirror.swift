import CoreGraphics

extension VectorPath {
    
    public func mirror(
        horizontal: Bool = false,
        vertical: Bool = false
    ) -> VectorPath {
        
        scale(by: CGSize(width: horizontal ? -1.0 : 1.0,
                         height: vertical ? -1.0 : 1.0))
    }
}
