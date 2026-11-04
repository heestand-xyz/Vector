import CoreGraphics
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers

enum SVGSnapshotRenderer {

    /// Fits the imported geometry into a square with the supplied pixel margin.
    /// Uses a one-pixel black stroke, no path fill, and a white background.
    static func png(path: CGPath, dimension: Int, padding: CGFloat) throws -> Data {
        try #require(dimension > 0 && padding >= 0 && padding * 2 < CGFloat(dimension))
        let bounds: CGRect = path.boundingBoxOfPath
        try #require(!bounds.isEmpty && !bounds.isInfinite && !bounds.isNull)
        let colorSpace: CGColorSpace = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let context: CGContext = try #require(CGContext(
            data: nil,
            width: dimension,
            height: dimension,
            bitsPerComponent: 8,
            bytesPerRow: dimension * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: dimension, height: dimension))
        let scale: CGFloat = min(
            (CGFloat(dimension) - padding * 2) / bounds.width,
            (CGFloat(dimension) - padding * 2) / bounds.height
        )
        context.translateBy(x: CGFloat(dimension) / 2, y: CGFloat(dimension) / 2)
        // Oriented SVG paths use positive Y downwards; bitmap contexts use Y upwards.
        context.scaleBy(x: scale, y: -scale)
        context.translateBy(x: -bounds.midX, y: -bounds.midY)
        context.setStrokeColor(CGColor(gray: 0, alpha: 1))
        context.setLineWidth(1 / scale)
        context.addPath(path)
        context.strokePath()

        let image: CGImage = try #require(context.makeImage())
        let data: NSMutableData = NSMutableData()
        let destination: CGImageDestination = try #require(CGImageDestinationCreateWithData(
            data as CFMutableData, UTType.png.identifier as CFString, 1, nil
        ))
        CGImageDestinationAddImage(destination, image, nil)
        try #require(CGImageDestinationFinalize(destination))
        return data as Data
    }

    /// Compares decoded pixels, excluding PNG compression and metadata differences.
    static func matches(_ actual: Data, _ expected: Data) throws -> Bool {
        let actualSource: CGImageSource = try #require(CGImageSourceCreateWithData(actual as CFData, nil))
        let expectedSource: CGImageSource = try #require(CGImageSourceCreateWithData(expected as CFData, nil))
        let actualImage: CGImage = try #require(CGImageSourceCreateImageAtIndex(actualSource, 0, nil))
        let expectedImage: CGImage = try #require(CGImageSourceCreateImageAtIndex(expectedSource, 0, nil))
        guard actualImage.width == expectedImage.width, actualImage.height == expectedImage.height else { return false }
        return try pixels(of: actualImage) == pixels(of: expectedImage)
    }

    private static func pixels(of image: CGImage) throws -> Data {
        let colorSpace: CGColorSpace = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let context: CGContext = try #require(CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: image.width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let bytes: UnsafeMutableRawPointer = try #require(context.data)
        return Data(bytes: bytes, count: context.bytesPerRow * context.height)
    }
}
