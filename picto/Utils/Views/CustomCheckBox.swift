import Foundation
import UIKit

final class CustomCheckBox: UIView {
    var isChecked = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        layer.borderWidth = 0.5
        layer.borderColor = UIColor.systemGray.cgColor
        layer.cornerRadius = frame.size.width / 2
        backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func toggle() {
        self.isChecked = !isChecked

        if self.isChecked {
            backgroundColor = .defined.cyan100()
            layer.borderColor = UIColor.black.cgColor
        } else {
            backgroundColor = .systemBackground
            layer.borderColor = UIColor.systemGray.cgColor
        }
    }
}
