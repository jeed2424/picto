#if canImport(UIKit) && !os(watchOS)
import Foundation
import UIKit

public extension UIImage {
    /// Generate a thumbnail
    ///
    /// - parameter target the CGSize
    /// - parameter keepAspectRatio the aspect ratio is to be preserved
    /// - Returns: The thumbnail
    func resize(_ target: CGSize, _ keepAspectRatio: Bool = true, _ orientation: UIImage.Orientation? = nil) -> UIImage {
        if keepAspectRatio {
            let scale: CGFloat = min(target.width / size.width, target.height / size.height)
            let scaledImage = scaledCopy(scale, orientation)

            let w: CGFloat = size.width * scale
            let h: CGFloat = size.height * scale
            let x: CGFloat = (target.width - w) / 2
            let y: CGFloat = (target.height - h) / 2
            let rect = CGRect(x: x, y: y, width: w, height: h)

            UIGraphicsBeginImageContextWithOptions(target, false, UIScreen.main.scale)
            scaledImage.draw(in: rect)
            let thumbnail: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return thumbnail.withRenderingMode(renderingMode)
        }

        UIGraphicsBeginImageContextWithOptions(target, false, UIScreen.main.scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let thumbnail: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return thumbnail.withRenderingMode(renderingMode)
    }

    /// Generate a resize copy of the original picture, with the new size specified as an absolute value.
    ///
    /// - parameters newSize: the actual size in pixels
    /// - parameters orientation: the orientation of the picture
    /// - returns: the newly resized image.
    func resizeToFit(_ newSize: CGFloat, _ orientation: UIImage.Orientation? = nil) -> UIImage {
        let scale: CGFloat = newSize / max(size.height, size.width)
        let scaledImage = scaledCopy(scale, orientation)
        let w: CGFloat = size.width * scale
        let h: CGFloat = size.height * scale
        let rect = CGRect(x: 0, y: 0, width: w, height: h)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        scaledImage.draw(in: rect)
        let thumbnail: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return thumbnail.withRenderingMode(renderingMode)
    }

    /// Generate a scaled copy
    ///
    /// - parameter scale
    /// - Returns: The scaled image
    func scaledCopy(_ scale: CGFloat, _ orientation: UIImage.Orientation? = nil) -> UIImage {
        UIImage(
            cgImage: cgImage!,
            scale: scale,
            orientation: orientation ?? imageOrientation
        ).withRenderingMode(renderingMode)
    }
}
#endif
