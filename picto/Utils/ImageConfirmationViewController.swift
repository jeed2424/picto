import Foundation
import UIKit
import Combine

class ImageConfirmationViewController: UIView {

    var subscriptions = CompositeCancellable()
    private(set) var viewModel: ViewModel
    var nextButtonTapPublisher = PassthroughSubject<Void, Never>()
    var cancelButtonTapPublisher = PassthroughSubject<Void, Never>()

    // MARK: - UI Components

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var alertDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    lazy var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0.5

        return view
    }()

    private lazy var btnCancel: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.titleLabel?.textAlignment = .center
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)

        button.addTarget(self, action: #selector(didTapCancelButton(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var btnNext: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.titleLabel?.textAlignment = .center
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)

        button.addTarget(self, action: #selector(didTapNextButton(_:)), for: .touchUpInside)

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
extension ImageConfirmationViewController {
    private func setupStyle() {
        backgroundColor = .black
    }

    private func setupConstraints() {

        addSubviews([
            imageView,
            bottomView
            ])

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        bottomView.addSubviews([
            btnCancel,
            btnNext
        ])

        NSLayoutConstraint.activate([
            btnCancel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 15),
            btnCancel.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            btnNext.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -15),
            btnNext.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor)
        ])

    }
}

// MARK: - Binding
extension ImageConfirmationViewController {
    private func bindViewModel() {
        subscriptions += viewModel.$image.sink { [weak self] image in
            self?.imageView.image = image
        }
    }
}

// MARK: - Actions
extension ImageConfirmationViewController {
    @objc private func didTapCancelButton(_ sender: UIButton) {
        cancelButtonTapPublisher.send()
    }

    @objc private func didTapNextButton(_ sender: UIButton) {
        nextButtonTapPublisher.send()
    }
}

// MARK: - ViewModel
extension ImageConfirmationViewController {
    final class ViewModel: ObservableObject {
        @Published var image: UIImage?

        init(image: UIImage?) {
            self.image = image
        }
    }
}

