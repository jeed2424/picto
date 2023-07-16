import Foundation
import UIKit
import Combine

class CustomAlertView: UIView {

    var subscriptions = CompositeCancellable()
    private(set) var viewModel: ViewModel
    var rightButtonTapPublisher = PassthroughSubject<Void, Never>()
    var leftButtonTapPublisher = PassthroughSubject<Void, Never>()

    // MARK: - UI Components
    lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20

        return stack
    }()

    lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 30

        return stack
    }()

    private lazy var alertTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center

        return label
    }()

    private lazy var alertDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.titleLabel?.textAlignment = .center
        button.setTitle("", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)

        button.addTarget(self, action: #selector(didTapLeftButton(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.titleLabel?.textAlignment = .center
        button.setTitle("", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)

        button.addTarget(self, action: #selector(didTapRightButton(_:)), for: .touchUpInside)

        return button
    }()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupStyle()
        setupConstraints()
        bindViewModel()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: UI
extension CustomAlertView {
    private func setupStyle() {
        backgroundColor = .white
        self.alpha = 0.85
    }

    private func setupConstraints() {
        addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])

        vStack.addArrangedSubviews([
            alertTitle,
            alertDescription,
            hStack
        ])

        hStack.addArrangedSubviews([
            leftButton,
            rightButton
        ])
    }
}

// MARK: - Binding
extension CustomAlertView {
    private func bindViewModel() {
        subscriptions += viewModel.$title.sink { [weak self] title in
            self?.alertTitle.text = title
        }
        subscriptions += viewModel.$descriptionText.sink { [weak self] descriptionText in
            self?.alertDescription.text = descriptionText
        }
        subscriptions += viewModel.$leftButtonTitle.sink { [weak self] leftButtonTitle in
            if leftButtonTitle?.isEmpty ?? true || leftButtonTitle == "" {
                self?.leftButton.removeFromSuperview()
            } else {
                self?.leftButton.setTitle(leftButtonTitle, for: .normal)

           //     self?.leftButton.titleLabel?.text = leftButtonTitle
            }
        }
        subscriptions += viewModel.$rightButtonTitle.sink { [weak self] rightButtonTitle in
            if rightButtonTitle?.isEmpty ?? true || rightButtonTitle == "" {
                self?.rightButton.removeFromSuperview()
            } else {
                self?.rightButton.setTitle(rightButtonTitle, for: .normal)
            //    self?.rightButton.titleLabel?.text = rightButtonTitle
            }
        }
    }
}

// MARK: - Actions
extension CustomAlertView {
    @objc private func didTapLeftButton(_ sender: UIButton) {
        leftButtonTapPublisher.send()
    }

    @objc private func didTapRightButton(_ sender: UIButton) {
        rightButtonTapPublisher.send()
    }
}

// MARK: - ViewModel
extension CustomAlertView {
    final class ViewModel: ObservableObject {
        @Published var title: String?
        @Published var descriptionText: String?
        @Published var leftButtonTitle: String?
        @Published var rightButtonTitle: String?

        init(title: String?, descriptionText: String?, leftButtonTitle: String?, rightButtonTitle: String?) {
            self.title = title
            self.descriptionText = descriptionText
            self.leftButtonTitle = leftButtonTitle
            self.rightButtonTitle = rightButtonTitle
        }
    }
}
