import SwiftUI
import CoreGraphics

public struct VectorPath {
    
    public let cgPath: CGPath
    
    public var path: Path {
        Path(cgPath)
    }
    
    let closed: Bool
    
    public init(cgPath: CGPath, closed: Bool) {
        self.cgPath = cgPath
        self.closed = closed
    }
    
    public init(path: Path, closed: Bool) {
        self.cgPath = path.cgPath
        self.closed = closed
    }
}

extension VectorPath {
    
    public static let empty = VectorPath(cgPath: CGMutablePath(),
                                         closed: false)
}
