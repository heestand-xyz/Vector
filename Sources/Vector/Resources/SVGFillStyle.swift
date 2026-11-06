import CoreGraphics
import Foundation

/// The inherited presentation attributes needed to convert filled SVG geometry.
struct SVGFillStyle: Sendable {

    enum Rule: Sendable {
        case winding
        case evenOdd
    }

    static let initial: SVGFillStyle = SVGFillStyle(rule: .winding, paintsInterior: true)

    let rule: Rule
    let paintsInterior: Bool

    func resolving(attributes: [String: String]) throws -> SVGFillStyle {
        let resolvedRule: Rule
        switch attributes["fill-rule"]?.trimmingCharacters(in: .whitespacesAndNewlines) {
        case nil, "inherit", "unset":
            resolvedRule = rule
        case "nonzero", "initial":
            resolvedRule = .winding
        case "evenodd":
            resolvedRule = .evenOdd
        case let value?:
            throw VectorPath.SVGError.invalidAttribute(name: "fill-rule", value: value)
        }

        let resolvedPaintsInterior: Bool
        switch attributes["fill"]?.trimmingCharacters(in: .whitespacesAndNewlines) {
        case nil, "inherit", "unset":
            resolvedPaintsInterior = paintsInterior
        case "none":
            resolvedPaintsInterior = false
        default:
            resolvedPaintsInterior = true
        }
        return SVGFillStyle(rule: resolvedRule, paintsInterior: resolvedPaintsInterior)
    }

    func convert(path: CGPath, closed: Bool) -> VectorPath {
        guard paintsInterior, rule == .evenOdd else {
            return VectorPath(cgPath: path, closed: closed)
        }
        // Resolve each element separately before combining it with other SVG elements.
        // Union uses the supplied fill rule and implicitly closes filled open subpaths.
        // Its output has normalized boundaries that fill identically with either rule.
        let normalizedPath: CGPath = path.union(path, using: .evenOdd)
        return VectorPath(cgPath: normalizedPath, closed: !normalizedPath.isEmpty)
    }
}
