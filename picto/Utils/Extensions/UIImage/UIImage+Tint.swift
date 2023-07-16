#if canImport(UIKit) && !os(watchOS)
import Foundation
import UIKit

public extension UIImage {

    /// Tint an image with specified color
    /// - parameter tint The tint
    /// - Returns: the new image with tainted properties
    func tint(_ tintColor: UIColor) -> UIImage? {
        let bounds = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size, format: UIGraphicsImageRendererFormat.transparent())
        if let cgImage = self.cgImage {
            return renderer.image { context in
                let cgContext: CGContext = context.cgContext
                cgContext.translateBy(x: 0, y: self.size.height)
                cgContext.scaleBy(x: 1.0, y: -1.0)
                // draw tint color
                cgContext.setBlendMode(CGBlendMode.normal)
                cgContext.setFillColor(tintColor.cgColor)
                cgContext.fill(bounds)
                // mask by alpha values of original image
                cgContext.setBlendMode(CGBlendMode.destinationIn)
                cgContext.draw(cgImage, in: bounds)
            }
        }
        return nil
    }

    /// Tint an image using a gradient color
    /// - parameter Colors: The colors to taint
    /// - parameter vertical: If the gradient is vertical
    /// - Returns: The tinted image
    func tintGradient(colors: [UIColor], vertical: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        context.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        // Create gradient
        let colors = colors.map { $0.cgColor } as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil)

        // Apply gradient
        context.clip(to: rect, mask: cgImage!)
        if vertical {
            context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: .drawsAfterEndLocation)
        } else {
            context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: 0), options: .drawsAfterEndLocation)
        }
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return gradientImage!
    }
}
#endif
