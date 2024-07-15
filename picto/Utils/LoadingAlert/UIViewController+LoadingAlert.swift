import UIKit

extension UIViewController {
    
    public func presentLoadingAlertModal(animated: Bool, completion: (() -> Void)?) {
        let viewController = LoadingAlertController()
        present(viewController, animated: animated, completion: completion)
    }
    
    public func dismissLoadingAlertModal(animated: Bool, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            guard self.presentedViewController is LoadingAlertController else {
                completion?()
                return
            }

            self.dismiss(animated: animated, completion: completion)
        }
    }
    
    public func bindLoadingAlertModal(to completion: (() -> Void)? = nil) -> (() -> Void) {
        presentLoadingAlertModal(animated: true, completion: nil)
        return { [weak self] in
            self?.dismissLoadingAlertModal(animated: true) {
                completion?()
            }
        }
    }
    
    public func bindLoadingAlertModal<T>(to completion: ((T) -> Void)?) -> ((T) -> Void) {
        presentLoadingAlertModal(animated: true, completion: nil)
        return { [weak self] param in
            self?.dismissLoadingAlertModal(animated: true) {
                completion?(param)
            }
        }
    }
}
