#if !os(macOS) && !os(watchOS)
import Foundation
import UIKit

public extension UIScrollView {
    /// Scroll to subview
    ///
    /// - parameter view The subview
    func scrollToSubview(_ view: UIView) {
        var rect = view.convert(view.bounds, to: self)
        if let accessoryView = view.inputAccessoryView {
            rect = CGRect(
                x: rect.origin.x,
                y: rect.origin.y + accessoryView.frame.size.height,
                width: rect.size.width,
                height: rect.size.height + accessoryView.frame.size.height
            )
        }
        scrollRectToVisible(rect, animated: true)
    }
}
#endif
