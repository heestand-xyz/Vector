//
//  File.swift
//  
//
//  Created by Anton Heestand on 2024-03-02.
//

import CoreGraphics

extension VectorPath {
    
    public func contains(_ point: CGPoint) -> Bool {
        cgPath.contains(point)
    }
}
