import CoreGraphics
import Foundation

enum SVGTransformParser {

    static func numbers(_ text: String, attribute: String) throws -> [CGFloat] {
        let scanner: Scanner = Scanner(string: text)
        scanner.locale = Locale(identifier: "en_US_POSIX")
        scanner.charactersToBeSkipped = nil
        var values: [CGFloat] = []
        _ = scanner.scanCharacters(from: .whitespacesAndNewlines)
        while !scanner.isAtEnd {
            guard let value: Double = scanner.scanDouble(), value.isFinite else {
                throw VectorPath.SVGError.invalidAttribute(name: attribute, value: text)
            }
            values.append(CGFloat(value))
            let whitespace: String? = scanner.scanCharacters(from: .whitespacesAndNewlines)
            if scanner.isAtEnd { break }
            if scanner.scanString(",") != nil {
                _ = scanner.scanCharacters(from: .whitespacesAndNewlines)
                guard !scanner.isAtEnd else {
                    throw VectorPath.SVGError.invalidAttribute(name: attribute, value: text)
                }
            } else if whitespace == nil {
                throw VectorPath.SVGError.invalidAttribute(name: attribute, value: text)
            }
        }
        return values
    }

    static func parse(_ text: String) throws -> CGAffineTransform {
        let scanner: Scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = .whitespacesAndNewlines
        var result: CGAffineTransform = .identity
        while !scanner.isAtEnd {
            guard let name: String = scanner.scanCharacters(from: .letters),
                  scanner.scanString("(") != nil else {
                throw VectorPath.SVGError.invalidAttribute(name: "transform", value: text)
            }
            let arguments: String = scanner.scanUpToString(")") ?? ""
            guard scanner.scanString(")") != nil else {
                throw VectorPath.SVGError.invalidAttribute(name: "transform", value: text)
            }
            let values: [CGFloat] = try numbers(arguments, attribute: "transform")
            let operation: CGAffineTransform
            switch (name, values.count) {
            case ("matrix", 6):
                operation = CGAffineTransform(a: values[0], b: values[1], c: values[2], d: values[3], tx: values[4], ty: values[5])
            case ("translate", 1), ("translate", 2):
                operation = CGAffineTransform(translationX: values[0], y: values.count == 2 ? values[1] : 0)
            case ("scale", 1), ("scale", 2):
                operation = CGAffineTransform(scaleX: values[0], y: values.count == 2 ? values[1] : values[0])
            case ("rotate", 1):
                operation = CGAffineTransform(rotationAngle: values[0] * .pi / 180)
            case ("rotate", 3):
                operation = CGAffineTransform(translationX: values[1], y: values[2])
                    .rotated(by: values[0] * .pi / 180)
                    .translatedBy(x: -values[1], y: -values[2])
            case ("skewX", 1):
                operation = CGAffineTransform(a: 1, b: 0, c: tan(values[0] * .pi / 180), d: 1, tx: 0, ty: 0)
            case ("skewY", 1):
                operation = CGAffineTransform(a: 1, b: tan(values[0] * .pi / 180), c: 0, d: 1, tx: 0, ty: 0)
            default:
                throw VectorPath.SVGError.invalidAttribute(name: "transform", value: text)
            }
            // SVG lists act like nested groups: the rightmost operation acts on a point first.
            result = operation.concatenating(result)
            guard [result.a, result.b, result.c, result.d, result.tx, result.ty].allSatisfy(\.isFinite) else {
                throw VectorPath.SVGError.invalidAttribute(name: "transform", value: text)
            }
            if scanner.scanString(",") != nil, scanner.isAtEnd {
                throw VectorPath.SVGError.invalidAttribute(name: "transform", value: text)
            }
        }
        return result
    }
}
