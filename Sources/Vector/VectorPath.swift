import SwiftUI
import CoreGraphics

public struct VectorPath {
    
    public let cgPath: CGPath
    
    public var path: Path {
        Path(cgPath)
    }
    
    public init(cgPath: CGPath) {
        self.cgPath = cgPath
    }
    
    public init(path: Path) {
        self.cgPath = path.cgPath
    }
}

extension VectorPath {
    public static let empty = VectorPath(cgPath: CGMutablePath())
}
