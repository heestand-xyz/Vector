import CoreGraphics
import Foundation

/// Converts basic SVG shapes into the same Y-up path representation as SVGPath.
struct SVGShapeParser {

    static let elementNames: Set<String> = ["rect", "circle", "ellipse", "line", "polyline", "polygon"]

    let attributes: [String: String]
    let viewportSize: CGSize

    func path(for name: String) throws -> VectorPath? {
        let path: CGMutablePath = CGMutablePath()
        let closed: Bool
        switch name {
        case "rect":
            let width: CGFloat = try dimension("width", relativeTo: viewportSize.width) ?? 0
            let height: CGFloat = try dimension("height", relativeTo: viewportSize.height) ?? 0
            guard width > 0, height > 0 else { return nil }
            let x: CGFloat = try length("x", relativeTo: viewportSize.width) ?? 0
            let y: CGFloat = try length("y", relativeTo: viewportSize.height) ?? 0
            let specifiedRX: CGFloat? = try dimension("rx", relativeTo: width)
            let specifiedRY: CGFloat? = try dimension("ry", relativeTo: height)
            let rx: CGFloat = min(specifiedRX ?? specifiedRY ?? 0, width / 2)
            let ry: CGFloat = min(specifiedRY ?? specifiedRX ?? 0, height / 2)
            let frame: CGRect = CGRect(x: x, y: y, width: width, height: height)
            if rx > 0, ry > 0 {
                path.addRoundedRect(in: frame, cornerWidth: rx, cornerHeight: ry)
            } else {
                path.addRect(frame)
            }
            closed = true
        case "circle", "ellipse":
            let cx: CGFloat = try length("cx", relativeTo: viewportSize.width) ?? 0
            let cy: CGFloat = try length("cy", relativeTo: viewportSize.height) ?? 0
            let rx: CGFloat
            let ry: CGFloat
            if name == "circle" {
                let normalizedDiagonal: CGFloat = hypot(viewportSize.width, viewportSize.height) / sqrt(2)
                let radius: CGFloat = try dimension("r", relativeTo: normalizedDiagonal) ?? 0
                rx = radius
                ry = radius
            } else {
                let specifiedRX: CGFloat? = try dimension("rx", relativeTo: viewportSize.width)
                let specifiedRY: CGFloat? = try dimension("ry", relativeTo: viewportSize.height)
                rx = specifiedRX ?? specifiedRY ?? 0
                ry = specifiedRY ?? specifiedRX ?? 0
            }
            guard rx > 0, ry > 0 else { return nil }
            path.addEllipse(in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
            closed = true
        case "line":
            let x1: CGFloat = try length("x1", relativeTo: viewportSize.width) ?? 0
            let y1: CGFloat = try length("y1", relativeTo: viewportSize.height) ?? 0
            let x2: CGFloat = try length("x2", relativeTo: viewportSize.width) ?? 0
            let y2: CGFloat = try length("y2", relativeTo: viewportSize.height) ?? 0
            path.move(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x2, y: y2))
            closed = false
        case "polyline", "polygon":
            guard let points: String = attributes["points"] else { return nil }
            let coordinates: [CGFloat] = try SVGTransformParser.numbers(points, attribute: "points")
            guard coordinates.count.isMultiple(of: 2) else {
                throw VectorPath.SVGError.invalidAttribute(name: "points", value: points)
            }
            guard !coordinates.isEmpty else { return nil }
            path.move(to: CGPoint(x: coordinates[0], y: coordinates[1]))
            for index: Int in stride(from: 2, to: coordinates.count, by: 2) {
                path.addLine(to: CGPoint(x: coordinates[index], y: coordinates[index + 1]))
            }
            closed = name == "polygon"
            if closed { path.closeSubpath() }
        default:
            throw VectorPath.SVGError.unsupportedElement(name)
        }

        var reflection: CGAffineTransform = CGAffineTransform(scaleX: 1, y: -1)
        guard let reflectedPath: CGPath = path.copy(using: &reflection) else {
            throw VectorPath.SVGError.transformFailed
        }
        return VectorPath(cgPath: reflectedPath, closed: closed)
    }

    /// Missing dimensions and SVG 2's `auto` radii are resolved by each shape.
    private func dimension(_ name: String, relativeTo reference: CGFloat) throws -> CGFloat? {
        if attributes[name]?.trimmingCharacters(in: .whitespacesAndNewlines) == "auto" { return nil }
        guard let value: CGFloat = try length(name, relativeTo: reference) else { return nil }
        guard value >= 0 else {
            throw VectorPath.SVGError.invalidAttribute(name: name, value: String(describing: value))
        }
        return value
    }

    /// Geometry attributes accept user units, pixels, and viewport-relative percentages.
    private func length(_ name: String, relativeTo reference: CGFloat) throws -> CGFloat? {
        guard let text: String = attributes[name] else { return nil }
        let scanner: Scanner = Scanner(string: text.trimmingCharacters(in: .whitespacesAndNewlines))
        scanner.locale = Locale(identifier: "en_US_POSIX")
        scanner.charactersToBeSkipped = nil
        guard let number: Double = scanner.scanDouble(), number.isFinite else {
            throw VectorPath.SVGError.invalidAttribute(name: name, value: text)
        }
        let unit: String = String(scanner.string[scanner.currentIndex...])
        let value: CGFloat
        switch unit {
        case "", "px":
            value = CGFloat(number)
        case "%":
            value = CGFloat(number) / 100 * reference
        default:
            throw VectorPath.SVGError.invalidAttribute(name: name, value: text)
        }
        guard value.isFinite else {
            throw VectorPath.SVGError.invalidAttribute(name: name, value: text)
        }
        return value
    }
}
