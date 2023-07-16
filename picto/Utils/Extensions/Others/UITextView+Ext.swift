import Foundation
import UIKit


extension UITextView {
    @objc var substituteFontName : String {
        get {
            return self.font?.fontName ?? "";
        }
        set {
            let fontNameToTest = self.font?.fontName.lowercased() ?? "";
            var fontName = newValue;
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold";
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium";
            } else if fontNameToTest.range(of: "regular") != nil {
                fontName += "-Regular";
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light";
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight";
            }
            self.font = UIFont(name: fontName, size: self.font?.pointSize ?? 17)
        }
    }

    func checkPlaceholder(placeholder: String, color: UIColor = .label) -> String {
        if self.text!.isEmpty || self.text! == placeholder {
            self.textColor = .systemGray
            return placeholder
        } else {
            self.textColor = color
            return self.text!
        }
    }
}
