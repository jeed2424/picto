import Foundation
import UIKit
//import YPImagePicker

final class BaseNC: UINavigationController {

    // MARK: - Lifecycle
    
    var forMain = false

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // This needs to be in here, not in init
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.isEnabled = true
        if forMain == true {
            
        } else {
            self.makeNavigationBarTransparent()
        }

    }
    
    @objc override func popVC() {
        self.popViewController(animated: true)
    }

    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }

    // MARK: - Overrides

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        duringPushAnimation = true

        super.pushViewController(viewController, animated: animated)
    }

    // MARK: - Private Properties

    fileprivate var duringPushAnimation = false

}

// MARK: - UINavigationControllerDelegate

extension BaseNC: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let swipeNavigationController = navigationController as? BaseNC else { return }

        swipeNavigationController.duringPushAnimation = false
    }

}

// MARK: - UIGestureRecognizerDelegate

extension BaseNC: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true // default value
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UINavigationController {
    func makeNavigationBarTransparent() {
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
    }
}

import Firebase

class CustomTabBarController: UITabBarController {
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    func set(selectedIndex index : Int) {
        _ = self.tabBarController(self, shouldSelect: self.viewControllers![index])
    }
}

extension CustomTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false // Make sure you want this as false
        }

        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.1, options: [.transitionCrossDissolve], completion: { (true) in

            })

            self.selectedViewController = viewController
        }
        
        let index = viewControllers?.firstIndex(of: viewController)

        return true
    }
}

class MyTransition: NSObject, UIViewControllerAnimatedTransitioning {

    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.15

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
            else {
                transitionContext.completeTransition(false)
                return
        }

        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
//        let quarterFrame = frame.width * 0.25
        let quarterFrame = frame.width
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - quarterFrame : frame.origin.x + quarterFrame
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + quarterFrame : frame.origin.x - quarterFrame
        toView.frame = toFrameStart

        let toCoverView = fromView.snapshotView(afterScreenUpdates: false)
        if let toCoverView = toCoverView {
            toView.addSubview(toCoverView)
        }
        let fromCoverView = toView.snapshotView(afterScreenUpdates: false)
        if let fromCoverView = fromCoverView {
            fromView.addSubview(fromCoverView)
        }

        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: [.curveEaseOut], animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
                toCoverView?.alpha = 0
                fromCoverView?.alpha = 1
            }) { (success) in
                fromCoverView?.removeFromSuperview()
                toCoverView?.removeFromSuperview()
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            }
        }
    }

    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
}

//import Firebas
extension UIViewController {
    func setFeedTopButtons(leftBtn: UIButton, rightBtn: UIButton, rightEnabled: Bool = true) {
        let btnLeft   = leftBtn
        btnLeft.frame =  CGRect(x: 0, y: 0, width: 100, height: 34)
        btnLeft.tintColor = rightEnabled ? UIColor.label.withAlphaComponent(0.3) : UIColor.label
        btnLeft.titleLabel?.font = BaseFont.get(.bold, 17)
        btnLeft.setTitle("Following", for: .normal)
        btnLeft.backgroundColor = UIColor.clear
        
        let btnRight   = rightBtn
        btnRight.frame =  CGRect(x: 0, y: 0, width: 70, height: 34)
        btnRight.tintColor = rightEnabled ? UIColor.label : UIColor.label.withAlphaComponent(0.3)
        btnRight.titleLabel?.font = BaseFont.get(.bold, 17)
        btnRight.setTitle("Discover", for: .normal)
        btnRight.backgroundColor = UIColor.clear
        
        let view = UIStackView(frame: CGRect(x: 0, y: 0, width: 180, height: 34))
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 0
        view.addArrangedSubview(btnLeft)
        view.addArrangedSubview(btnRight)
        
        let mainTitleView = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 34))
        mainTitleView.addSubview(view)
        navigationItem.titleView = mainTitleView
    }
    
    func setLeftAvatarItem() {
        let profile = ProfileService.make()
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        imgView.layer.cornerRadius = 17
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.backgroundColor = .systemGray6
     //   imgView.setImage(string: profile.user!.avatar!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.logout))
        imgView.addGestureRecognizer(tap)
        imgView.isUserInteractionEnabled = true
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        v.backgroundColor = .clear
        v.addSubview(imgView)
        let btn = UIBarButtonItem(customView: v)
        self.navigationItem.setLeftBarButton(btn, animated: false)
    }
    
    func setRighAvatarItem(user: BMUser) {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imgView.layer.cornerRadius = 15
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.backgroundColor = .systemGray6
        imgView.setImage(string: user.avatar!)
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        v.backgroundColor = .clear
        v.addSubview(imgView)
        let btn = UIBarButtonItem(customView: v)
        self.navigationItem.setRightBarButton(btn, animated: false)
    }
    
    
    @objc func logout() {
        AuthenticationService.make().logout {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
