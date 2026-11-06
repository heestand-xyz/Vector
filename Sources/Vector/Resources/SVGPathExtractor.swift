import CoreGraphics
import Foundation

/// Resolves path and basic shape geometry. Paint, stroke expansion, and CSS are not represented by VectorPath.
final class SVGPathExtractor: NSObject, XMLParserDelegate {

    private static let renderableElementNames: Set<String> = Set<String>(["svg", "g", "a", "path", "use"])
        .union(SVGShapeParser.elementNames)

    private final class Element {
        let name: String
        let attributes: [String: String]
        let isSVG: Bool
        var children: [Element] = []

        init(name: String, attributes: [String: String], namespace: String?) {
            self.name = name
            self.attributes = attributes
            self.isSVG = namespace == nil || namespace == "" || namespace == "http://www.w3.org/2000/svg"
        }
    }

    private var root: Element?
    private var stack: [Element] = []
    private var elementsByID: [String: Element] = [:]
    private var failure: VectorPath.SVGError?

    static func extract(data: Data) throws -> (viewBox: CGRect, paths: [VectorPath]) {
        let parser: XMLParser = XMLParser(data: data)
        let extractor: SVGPathExtractor = SVGPathExtractor()
        parser.shouldProcessNamespaces = true
        parser.shouldResolveExternalEntities = false
        parser.delegate = extractor
        let parsed: Bool = parser.parse()
        if let failure: VectorPath.SVGError = extractor.failure { throw failure }
        guard parsed else {
            throw VectorPath.SVGError.invalidDocument(parser.parserError?.localizedDescription ?? "The document is incomplete.")
        }
        guard let root: Element = extractor.root, root.isSVG, root.name == "svg" else {
            throw VectorPath.SVGError.invalidDocument("The root element must be \"svg\".")
        }
        guard let value: String = root.attributes["viewBox"] else {
            throw VectorPath.SVGError.svgViewBoxSizeNotFound
        }
        let values: [CGFloat] = try SVGTransformParser.numbers(value, attribute: "viewBox")
        guard values.count == 4, values[2] > 0, values[3] > 0 else {
            throw VectorPath.SVGError.svgViewBoxSizeNotFound
        }
        let viewBox: CGRect = CGRect(x: values[0], y: values[1], width: values[2], height: values[3])
        var paths: [VectorPath] = []
        try extractor.render(root, parentTransform: .identity, viewportSize: viewBox.size, ancestors: [], into: &paths)
        return (viewBox, paths)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        let element: Element = Element(name: elementName, attributes: attributeDict, namespace: namespaceURI)
        if let parent: Element = stack.last {
            parent.children.append(element)
        } else {
            root = element
        }
        stack.append(element)
        if element.isSVG, let id: String = attributeDict["id"] {
            guard elementsByID[id] == nil else {
                failure = .duplicateID(id)
                parser.abortParsing()
                return
            }
            elementsByID[id] = element
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        stack.removeLast()
    }

    private func render(_ element: Element, parentTransform: CGAffineTransform, viewportSize: CGSize,
                        ancestors: Set<ObjectIdentifier>, into paths: inout [VectorPath]) throws {
        guard element.isSVG else { return }
        // Definition and metadata subtrees are indexed but never painted directly.
        guard Self.renderableElementNames.contains(element.name) else { return }
        let identity: ObjectIdentifier = ObjectIdentifier(element)
        guard !ancestors.contains(identity) else {
            throw VectorPath.SVGError.circularReference("#\(element.attributes["id"] ?? element.name)")
        }
        var ancestors: Set<ObjectIdentifier> = ancestors
        ancestors.insert(identity)
        let localTransform: CGAffineTransform = try SVGTransformParser.parse(element.attributes["transform"] ?? "")
        var transform: CGAffineTransform = localTransform.concatenating(parentTransform)

        switch element.name {
        case "path", "rect", "circle", "ellipse", "line", "polyline", "polygon":
            let path: VectorPath
            if element.name == "path" {
                guard let pathData: String = element.attributes["d"], !pathData.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                path = try .svg(path: pathData)
            } else {
                let shapeParser: SVGShapeParser = SVGShapeParser(attributes: element.attributes, viewportSize: viewportSize)
                guard let shape: VectorPath = try shapeParser.path(for: element.name) else { return }
                path = shape
            }
            // SVGPath parses into Y-up coordinates. Conjugate the SVG-space transform
            // by the Y reflection, preserving the existing raw VectorPath API.
            var pathTransform: CGAffineTransform = CGAffineTransform(
                a: transform.a, b: -transform.b, c: -transform.c, d: transform.d,
                tx: transform.tx, ty: -transform.ty
            )
            guard let transformedPath: CGPath = path.cgPath.copy(using: &pathTransform) else {
                throw VectorPath.SVGError.transformFailed
            }
            paths.append(VectorPath(cgPath: transformedPath, closed: path.closed))
        case "use":
            guard let reference: String = element.attributes["href"] ?? element.attributes["xlink:href"] else {
                throw VectorPath.SVGError.missingReference("href")
            }
            guard reference.hasPrefix("#"), reference.count > 1 else {
                throw VectorPath.SVGError.unsupportedReference(reference)
            }
            guard let target: Element = elementsByID[String(reference.dropFirst())] else {
                throw VectorPath.SVGError.missingReference(reference)
            }
            guard target.name != "svg", Self.renderableElementNames.contains(target.name) else {
                throw VectorPath.SVGError.unsupportedReference(reference)
            }
            let x: CGFloat = try coordinate("x", in: element)
            let y: CGFloat = try coordinate("y", in: element)
            transform = CGAffineTransform(translationX: x, y: y).concatenating(transform)
            // A use inherits its own ancestors, not the referenced element's original ancestors.
            try render(target, parentTransform: transform, viewportSize: viewportSize, ancestors: ancestors, into: &paths)
        default:
            if element.name == "svg", element !== root {
                throw VectorPath.SVGError.unsupportedElement("nested svg")
            }
            for child: Element in element.children {
                try render(child, parentTransform: transform, viewportSize: viewportSize, ancestors: ancestors, into: &paths)
            }
        }
    }

    private func coordinate(_ name: String, in element: Element) throws -> CGFloat {
        guard let value: String = element.attributes[name] else { return 0 }
        let values: [CGFloat] = try SVGTransformParser.numbers(value, attribute: name)
        guard values.count == 1 else {
            throw VectorPath.SVGError.invalidAttribute(name: name, value: value)
        }
        return values[0]
    }
}
