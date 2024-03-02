//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2024-03-02.
//

import CoreGraphics

extension VectorPath {
    
    static func quadraticBezierPoint(t: CGFloat, start: CGPoint, controlPoint: CGPoint, end: CGPoint) -> CGPoint {
        let mt = 1 - t
        let mt2 = mt * mt
        let t2 = t * t
        let x = mt2 * start.x + 2 * mt * t * controlPoint.x + t2 * end.x
        let y = mt2 * start.y + 2 * mt * t * controlPoint.y + t2 * end.y
        return CGPoint(x: x, y: y)
    }
    
    static func cubicBezierPoint(t: CGFloat, start: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint, end: CGPoint) -> CGPoint {
        let mt = 1 - t
        let mt2 = mt * mt
        let mt3 = mt2 * mt
        let t2 = t * t
        let t3 = t2 * t
        let x = mt3 * start.x + 3 * mt2 * t * controlPoint1.x + 3 * mt * t2 * controlPoint2.x + t3 * end.x
        let y = mt3 * start.y + 3 * mt2 * t * controlPoint1.y + 3 * mt * t2 * controlPoint2.y + t3 * end.y
        return CGPoint(x: x, y: y)
    }
}
