//
//  File.swift
//  
//
//  Created by Anton Heestand on 2024-03-02.
//

import CoreGraphics

extension VectorPath {
    
    public func anchorPoints() -> [CGPoint] {

        var anchorPoints: [CGPoint] = []
        
        cgPath.applyWithBlock { elementPointer in
            
            let element = elementPointer.pointee
            
            switch element.type {
            case .moveToPoint:
                anchorPoints.append(element.points.pointee)
            case .addLineToPoint:
                anchorPoints.append(element.points.pointee)
            case .addQuadCurveToPoint:
                anchorPoints.append(element.points.advanced(by: 0).pointee)
                anchorPoints.append(element.points.advanced(by: 1).pointee)
            case .addCurveToPoint:
                anchorPoints.append(element.points.advanced(by: 0).pointee)
                anchorPoints.append(element.points.advanced(by: 1).pointee)
                anchorPoints.append(element.points.advanced(by: 2).pointee)
            case .closeSubpath:
                break
            default:
                break
            }
        }
        
        return anchorPoints
    }
}
