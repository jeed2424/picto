import UIKit
import CoreGraphics

internal extension CGColor {
    class defined {

        static func cyan50(traits: UITraitCollection? = nil) -> CGColor {
            UIColor(named: "cyan50", in: Bundle(for: UIColor.defined.self), compatibleWith: traits)!.cgColor
        }

        static func cyan100(traits: UITraitCollection? = nil) -> CGColor {
            UIColor(named: "cyan100", in: Bundle(for: UIColor.defined.self), compatibleWith: traits)!.cgColor
        }
    }
}
