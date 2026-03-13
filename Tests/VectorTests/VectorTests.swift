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

    func testCountPointsIncludeEndpoints() throws {

        let subPath = VectorSubPath(
            points: [
                .point(.zero),
                .point(CGPoint(x: 10.0, y: 0.0)),
                .point(CGPoint(x: 10.0, y: 10.0)),
            ],
            closed: false
        )

        let points: [CGPoint] = subPath.points(count: 3)

        XCTAssertEqual(points.count, 3)
        XCTAssertEqual(points[0], .zero)
        XCTAssertEqual(points[1], CGPoint(x: 10.0, y: 0.0))
        XCTAssertEqual(points[2], CGPoint(x: 10.0, y: 10.0))
    }

    func testCountPointsUseLastExplicitAnchorForClosedPath() throws {

        let subPath = VectorSubPath(
            points: [
                .point(.zero),
                .point(CGPoint(x: 2.0, y: 0.0)),
                .point(CGPoint(x: 2.0, y: 2.0)),
            ],
            closed: true
        )

        let points: [CGPoint] = subPath.points(count: 2)

        XCTAssertEqual(points.count, 2)
        XCTAssertEqual(points[0], .zero)
        XCTAssertEqual(points[1], CGPoint(x: 2.0, y: 2.0))
    }
    
    func testSVG() throws {
        let vectorPath: VectorPath = .rectangle(frame: .one)
        let svgData: Data = try vectorPath.svgFileData()
        let svgVectorPath: VectorPath = try .firstSVG(data: svgData)
        XCTAssertEqual(
            vectorPath.rawPoints(),
            svgVectorPath.rawPoints()
        )
    }
    
    func testOrientedSVG() throws {
        let vectorPath: VectorPath = .rectangle(frame: .one)
        let svgData: Data = try vectorPath.svgOrientedFileData()
        let svgVectorPath: VectorPath = try .firstOrientedSVG(data: svgData)
        XCTAssertEqual(
            vectorPath.rawPoints(),
            svgVectorPath.rawPoints()
        )
    }
}
