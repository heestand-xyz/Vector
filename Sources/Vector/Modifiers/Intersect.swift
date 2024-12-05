import SwiftUI
import CoreGraphics

extension VectorPath {
    
    public static func intersect(
        paths: [VectorPath]
    ) -> VectorPath {
        var cgPath: CGPath?
        for vectorPath in paths {
            if cgPath == nil {
                cgPath = vectorPath.cgPath
            } else {
                cgPath = cgPath!.intersection(vectorPath.cgPath)
            }
        }
        guard let cgPath: CGPath else { return .empty }
        return VectorPath(cgPath: cgPath, closed: !paths.contains(where: { !$0.closed }))
    }
}
