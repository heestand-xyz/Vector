import SwiftUI
@preconcurrency import CoreGraphics

public struct VectorPath: Sendable {
    
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

// TODO: Compare on ID if CGPath comparison is too heavy
extension VectorPath: Equatable, Hashable {
    
    public static func == (lhs: VectorPath, rhs: VectorPath) -> Bool {
        lhs.cgPath == rhs.cgPath
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cgPath)
    }
}
