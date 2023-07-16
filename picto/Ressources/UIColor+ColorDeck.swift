import UIKit

internal extension UIColor {
    class defined {

        static func cyan50(traits: UITraitCollection? = nil) -> UIColor {
            UIColor(named: "cyan50", in: Bundle(for: CGColor.defined.self), compatibleWith: traits)!
        }

        static func cyan100(traits: UITraitCollection? = nil) -> UIColor {
            UIColor(named: "cyan100", in: Bundle(for: CGColor.defined.self), compatibleWith: traits)!
        }
    }
}
