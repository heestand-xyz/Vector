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

    func testSelfIntersectionUnionNormalizesBowTie() throws {

        let vectorPath = VectorPath(
            subPath: VectorSubPath(
                points: [
                    .point(CGPoint(x: 0.0, y: 0.0)),
                    .point(CGPoint(x: 2.0, y: 2.0)),
                    .point(CGPoint(x: 0.0, y: 2.0)),
                    .point(CGPoint(x: 2.0, y: 0.0)),
                ],
                closed: true
            )
        )

        let normalized = vectorPath.selfIntersectionUnion(count: 32)
        let subPaths = normalized.subPaths()

        XCTAssertEqual(subPaths.count, 2)
        XCTAssertTrue(subPaths.allSatisfy(\.closed))
        XCTAssertTrue(normalized.contains(CGPoint(x: 1.0, y: 0.25)))
        XCTAssertTrue(normalized.contains(CGPoint(x: 1.0, y: 1.75)))
        XCTAssertFalse(normalized.contains(CGPoint(x: 0.25, y: 1.0)))
    }

    func testSelfIntersectionUnionPreservesHoleContours() throws {

        let vectorPath: VectorPath = .donut(
            position: .zero,
            radii: 0.5...1.0
        )

        let normalized = vectorPath.selfIntersectionUnion(count: 64)
        let subPaths = normalized.subPaths()

        XCTAssertEqual(subPaths.count, 2)
        XCTAssertTrue(subPaths.allSatisfy(\.closed))
        XCTAssertTrue(normalized.contains(CGPoint(x: 0.75, y: 0.0)))
        XCTAssertFalse(normalized.contains(.zero))
    }

    func testSubPathSelfIntersectionUnionCanSplitIntoMultipleContours() throws {

        let subPath = VectorSubPath(
            points: [
                .point(CGPoint(x: 0.0, y: 0.0)),
                .point(CGPoint(x: 4.0, y: 0.0)),
                .point(CGPoint(x: 4.0, y: 4.0)),
                .point(CGPoint(x: 0.0, y: 4.0)),
                .point(CGPoint(x: 0.0, y: 0.0)),
                .point(CGPoint(x: 1.0, y: 1.0)),
                .point(CGPoint(x: 1.0, y: 3.0)),
                .point(CGPoint(x: 3.0, y: 3.0)),
                .point(CGPoint(x: 3.0, y: 1.0)),
                .point(CGPoint(x: 1.0, y: 1.0)),
            ],
            closed: true
        )

        let normalizedSubPaths = subPath.selfIntersectionUnion(count: 64)
        let normalizedPath = VectorPath(subPaths: normalizedSubPaths)

        XCTAssertEqual(normalizedSubPaths.count, 2)
        XCTAssertTrue(normalizedSubPaths.allSatisfy(\.closed))
        XCTAssertTrue(normalizedPath.contains(CGPoint(x: 0.5, y: 0.5)))
        XCTAssertFalse(normalizedPath.contains(CGPoint(x: 2.0, y: 2.0)))
    }

    func testSelfIntersectionUnionKeepsOpenSubPathsUnchanged() throws {

        let subPath = VectorSubPath(
            points: [
                .point(.zero),
                .point(CGPoint(x: 1.0, y: 0.0)),
                .point(CGPoint(x: 2.0, y: 1.0)),
            ],
            closed: false
        )

        XCTAssertEqual(subPath.selfIntersectionUnion(count: 16), [subPath])
        XCTAssertEqual(VectorPath(subPath: subPath).selfIntersectionUnion(count: 16), VectorPath(subPath: subPath))
    }

    func testSelfIntersectionUnionSamplingVariantsProduceClosedOutput() throws {

        let vectorPath: VectorPath = .circle(radius: 1.0)

        let spacingResult = vectorPath.selfIntersectionUnion(spacing: 0.2)
        let spacingFractionResult = vectorPath.selfIntersectionUnion(spacingFraction: 0.05)
        let countResult = vectorPath.selfIntersectionUnion(count: 32)

        for result in [spacingResult, spacingFractionResult, countResult] {
            let subPaths = result.subPaths()
            XCTAssertFalse(subPaths.isEmpty)
            XCTAssertTrue(subPaths.allSatisfy(\.closed))
        }
    }
}
