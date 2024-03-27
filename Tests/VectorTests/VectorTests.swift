import XCTest
@testable import Vector

final class VectorTest: XCTestCase {
    
    func testCirclePoints() throws {
        
        let count: Int = 10
        let radius: CGFloat = 0.5
        
        let vectorPath: VectorPath = .circle(radius: radius)
        let points: [CGPoint] = vectorPath.points(spacingFraction: 1.0 / CGFloat(count))
        XCTAssertEqual(points.count, count)
        
        for (index, point) in points.enumerated() {
            let fraction = CGFloat(index) / CGFloat(count)
            let position = CGPoint(x: cos(fraction * .pi * 2) * radius,
                                   y: sin(fraction * .pi * 2) * radius)
            XCTAssertEqual(point.x, position.x, accuracy: 0.0001)
            XCTAssertEqual(point.y, position.y, accuracy: 0.0001)
        }
    }
}
