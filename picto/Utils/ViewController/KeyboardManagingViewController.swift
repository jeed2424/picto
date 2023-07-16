#if !os(macOS) && !os(tvOS) && !os(watchOS)
import Combine
import UIKit

open class KeyboardManagingViewController: UIViewController {

    /// The Cancellables
    private var cancellables = CompositeCancellable()

    /// Enable/disable scrollview offsets during keyboard events
    open var enableKeyboardManagement: Bool = true

    /// Enable/disable scrollview offsets during keyboard events
    open var enableTapAnywhereToDismiss: Bool = true

    /// Current first responder as setted by view controller. Otherwise defaults to the view.firstResponser()
    open var activeField: UIView?

    /// A content inset to apply on top of the standard content insent
    open var keyboardContentInset: UIEdgeInsets = .zero

    /// The content inset of the given scrollview before any keyboard handling
    open var defaultkeyboardManagingScrollViewContentInset: UIEdgeInsets = .zero

    /// Must be set to handle scrollview offsets during keyboard events
    open var keyboardManagingScrollView: UIScrollView? {
        didSet {
            defaultkeyboardManagingScrollViewContentInset = keyboardManagingScrollView?.contentInset ?? .zero
        }
    }

    /// The Screen Tap Gesture to dismiss the keyboard
    private lazy var keyboardDismissGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onScreenPressed))
        recognizer.cancelsTouchesInView = true
        return recognizer
    }()

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if enableKeyboardManagement {
            cancellables += UIResponder.keyboardDidShowNotification.publisher()
                .subscribeOnMain()
                .receiveOnMain().sink { notification in
                    if let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                        self.keyboardDidShow(value.cgRectValue.size)
                    } else {
                        self.keyboardDidShow(.zero)
                    }
                }

            cancellables += UIResponder.keyboardWillHideNotification
                .publisher()
                .subscribeOnMain()
                .receiveOnMain().sink { _ in
                    self.keyboardWillHide()
                }
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancellables.cancel()
    }

    open func keyboardDidShow(_ size: CGSize) {
        if enableTapAnywhereToDismiss {
            view.addGestureRecognizer(keyboardDismissGestureRecognizer)
        }

        if let scrollView = keyboardManagingScrollView {
            handleKeyboardOffset(scrollView, size)
        }
    }

    open func keyboardWillHide() {
        activeField = nil
        if enableTapAnywhereToDismiss {
            view.removeGestureRecognizer(keyboardDismissGestureRecognizer)
        }
        resetKeyboardOffset()
    }

    open func getFirstResponderForKeyboardManagement() -> UIView? {
        activeField ?? view.firstResponder()
    }

    open func handleKeyboardOffset(_ scrollView: UIScrollView, _ keyboardSize: CGSize) {
        let contentInsets = UIEdgeInsets(
            top: keyboardContentInset.top,
            left: 0,
            bottom: keyboardSize.height + keyboardContentInset.bottom,
            right: 0
        )
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        if let field = getFirstResponderForKeyboardManagement() {
            keyboardManagingScrollView?.scrollToSubview(field)
        }
    }

    open func resetKeyboardOffset() {
        if let scrollView = keyboardManagingScrollView {
            scrollView.contentInset = defaultkeyboardManagingScrollViewContentInset
            scrollView.scrollIndicatorInsets = .zero
        }
    }

    @objc
    private func onScreenPressed() {
        view.endEditing(true)

        // This is a hack to allow dismissal of the keyboard for iPad with split-views as an ancestor
        var currentSuperview = view.superview
        while currentSuperview != nil {
            currentSuperview!.endEditing(true)
            currentSuperview = currentSuperview?.superview
        }
    }
}
#endif
