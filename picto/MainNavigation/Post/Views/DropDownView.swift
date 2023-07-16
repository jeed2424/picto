import Foundation
import UIKit
import Combine

class DropDownView: UIView {

    private lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .horizontal
        stack.spacing = 10

        return stack
    }()

    lazy var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        return label
    }()

    private lazy var arrowImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)

        view.image = R.image.down_arrow()?.resize(CGSize(width: 20, height: 20))

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DropDownView {
    private func setupStyle() {

        addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            hStack.topAnchor.constraint(equalTo: topAnchor),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        hStack.addArrangedSubviews([
            title,
            arrowImage
        ])

        NSLayoutConstraint.activate([
            arrowImage.widthAnchor.constraint(equalToConstant: 20),
            arrowImage.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
