import Foundation

extension VectorPath {

    enum SVGError: LocalizedError, Equatable {
        case stringToDataFailed
        case dataToStringFailed
        case noVectorPathsFound
        case svgViewBoxSizeNotFound
        case invalidDocument(String)
        case invalidAttribute(name: String, value: String)
        case duplicateID(String)
        case missingReference(String)
        case unsupportedReference(String)
        case circularReference(String)
        case unsupportedElement(String)
        case transformFailed

        var errorDescription: String? {
            switch self {
            case .stringToDataFailed:
                "The SVG text could not be encoded. Save the SVG as UTF-8 and try again."
            case .dataToStringFailed:
                "The SVG data could not be read as text. Save the SVG as UTF-8 and try again."
            case .noVectorPathsFound:
                "No vector paths were found. Convert the artwork to paths before importing it."
            case .svgViewBoxSizeNotFound:
                "The SVG has no valid view box. Add a \"viewBox\" with a positive width and height."
            case .invalidDocument(let reason):
                "The SVG could not be parsed. Correct the XML and try again: \(reason)"
            case .invalidAttribute(let name, let value):
                "The SVG attribute \"\(name)\" has an invalid or unsupported value, \"\(value)\". Correct it and try again."
            case .duplicateID(let id):
                "The SVG repeats the ID \"\(id)\". Give each element a unique ID."
            case .missingReference(let reference):
                "The SVG reference \"\(reference)\" has no matching element. Correct the reference or add the missing element."
            case .unsupportedReference(let reference):
                "The SVG reference \"\(reference)\" is not supported. Use a local reference to a path, group, or use element."
            case .circularReference(let reference):
                "The SVG reference \"\(reference)\" creates a cycle. Remove the circular use reference."
            case .unsupportedElement(let name):
                "The SVG element \"\(name)\" is not supported here. Flatten it into paths and groups before importing it."
            case .transformFailed:
                "An SVG path could not be transformed. Check the artwork's transform values."
            }
        }
    }
}
