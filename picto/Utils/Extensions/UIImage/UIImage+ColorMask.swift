#if canImport(UIKit) && !os(watchOS)
import Foundation
import UIKit

/**
 A simple struct that allows to easily define a range of values for color masking.
 */
public struct ColorRange {
    private static let MIN = 0.cgf
    private static let MAX = 255.cgf
    private static let MAX_RANGE = ColorRange.MIN ... ColorRange.MAX

    /// The Lower Bound. 0 to 255
    public private(set) var lower: CGFloat = 0

    /// The Upper Bound. 0 to 255
    public private(set) var upper: CGFloat = 0

    /// Initialize
    ///
    /// - parameter lower The lower range value, between 0 and 255
    /// - parameter upper The upper range value, between 0 and 255
    public init(_ lower: CGFloat, _ upper: CGFloat) {
        precondition(lower <= upper)
        self.lower = ColorRange.MAX_RANGE.clampedValue(lower)
        self.upper = ColorRange.MAX_RANGE.clampedValue(upper)
    }
}

/**
 A convenience struct to define a trio of color ranges for color masking
 */
public struct ColorRanges {
    private static let MIN = 0.cgf
    private static let MAX = 255.cgf
    private static let MAX_RANGE = ColorRanges.MIN ... ColorRanges.MAX

    /// Red Color Range
    public private(set) var red = ColorRange(0, 255)

    /// Green Color Range
    public private(set) var green = ColorRange(0, 255)

    /// Blue Color Range
    public private(set) var blue = ColorRange(0, 255)

    /// Initialize
    ///
    /// - parameter red The Red range
    /// - parameter green The Green Range
    /// - parameter blue The Blue Range
    public init(red: ColorRange, green: ColorRange, blue: ColorRange) {
        self.red = red
        self.blue = blue
        self.green = green
    }

    /// A convenience init that takes a single color, and apply a fudging offset
    ///
    /// - parameter color The source color
    /// - parameter fuzz The Fudging Offset
    public init(_ color: UIColor, _ fuzz: CGFloat = 0.0) {
        var (red1, green1, blue1, alpha1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        color.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)

        let adjustment = ColorRanges.MAX_RANGE.clampedValue(fuzz)
        red = ColorRange(red1 - adjustment, red1 + adjustment)
        green = ColorRange(green1 - adjustment, green1 + adjustment)
        blue = ColorRange(blue1 - adjustment, blue1 + adjustment)
    }

    /// A convenience init that takes 2 color as range, and apply a fudging offset
    ///
    /// - parameter lower The lower range color
    /// - parameter upper The upper range color
    /// - parameter fuzz The Fudging Offset
    public init(_ lower: UIColor, _ upper: UIColor, _ fuzz: CGFloat = 0.0) {
        var (red1, green1, blue1, alpha1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        lower.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)

        var (red2, green2, blue2, alpha2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        upper.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        let adjustment = ColorRanges.MAX_RANGE.clampedValue(fuzz)
        red = ColorRange(red1 - adjustment, red2 + adjustment)
        green = ColorRange(green1 - adjustment, green2 + adjustment)
        blue = ColorRange(blue1 - adjustment, blue2 + adjustment)
    }
}

public extension UIGraphicsImageRendererFormat {
    /// Utility method that returns a transparent image render format
    static func transparent() -> UIGraphicsImageRendererFormat {
        let value = UIGraphicsImageRendererFormat()
        value.opaque = false
        return value
    }

    /// Utility method that returns a opaque image render format
    static func opaque() -> UIGraphicsImageRendererFormat {
        let value = UIGraphicsImageRendererFormat()
        value.opaque = true
        return value
    }
}

public extension UIImage {
    /// Render an image without it's alpha channel. Removing any transparency
    func withNoAlphaChannel() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size, format: UIGraphicsImageRendererFormat.opaque())
        return renderer.image { _ in
            self.draw(at: .zero)
        }
    }

    /// Mask an image's color with a substitute color
    ///
    /// - parameter color the color to use
    /// - parameter range the range to replace
    func withColorMasked(_ color: UIColor, _ range: ColorRanges) -> UIImage? {
        let maskingColors: [CGFloat] = [range.red.lower, range.red.upper, range.green.lower, range.green.upper, range.blue.lower, range.blue.upper]
        let bounds = CGRect(origin: .zero, size: size)

        // make sure image has no alpha channel
        if let imageToMask = cgImage, let maskedImage = withNoAlphaChannel()
            .cgImage?
            .copy(maskingColorComponents: maskingColors) {
            let renderer = UIGraphicsImageRenderer(size: size, format: UIGraphicsImageRendererFormat.transparent())
            return renderer.image { context in

                let cgContext: CGContext = context.cgContext
                cgContext.translateBy(x: 0, y: self.size.height)
                cgContext.scaleBy(x: 1.0, y: -1.0)
                cgContext.clip(to: bounds, mask: imageToMask)
                cgContext.setFillColor(color.cgColor)
                cgContext.fill(bounds)
                cgContext.draw(maskedImage, in: bounds)
            }
        }
        return nil
    }
}
#endif
