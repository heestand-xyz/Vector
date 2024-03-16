import SwiftUI
import CoreGraphics

extension VectorPath {
    
    public static func combine(
        paths: [VectorPath]
    ) -> VectorPath {
        let cgPath = CGMutablePath()
        for vectorPath in paths {
            cgPath.addPath(vectorPath.cgPath)
        }
        return VectorPath(cgPath: cgPath, closed: !paths.contains(where: { !$0.closed }))
    }
}
