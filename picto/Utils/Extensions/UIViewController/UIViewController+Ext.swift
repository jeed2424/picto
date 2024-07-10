import Foundation
import UIKit
import PixelSDK
import Photos

extension UIViewController {

    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
    
    func setNavTitle(text: String, font: UIFont, letterSpacing: CGFloat = 0.1, color: UIColor = .label) {

        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.kern: letterSpacing, NSAttributedString.Key.foregroundColor: color]
        self.navigationItem.title = text
    }

    func setLargeNavTitle(text: String, font: UIFont, letterSpacing: CGFloat = 0.1, color: UIColor = .label) {

        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font.withSize(18), NSAttributedString.Key.kern: letterSpacing, NSAttributedString.Key.foregroundColor: color]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.kern: letterSpacing, NSAttributedString.Key.foregroundColor: color]
        self.navigationItem.title = text
    }

    @objc func setRightNavBtn(image: UIImage, color: UIColor = .label, action: Selector, animated: Bool = false) {
        let btn = UIBarButtonItem(image: image, style: .done, target: self, action: action)
        btn.tintColor = color
        self.navigationItem.setRightBarButton(btn, animated: animated)
    }

    @objc func setRightNavBtnInbox(hasUnread: Bool, image: UIImage, color: UIColor = .label, action: Selector, animated: Bool = false) {
//        let btn1 = Custom
//        let btn = CustomBarButton(image: image, style: .done, target: self, action: action)
        let btn2 = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        btn2.setImage(image.withTintColor(color), for: [])
//        btn2.titleLabel?.font = font
//        btn2.setTitleColor(color, for: [])
        btn2.addTarget(self, action: action, for: .touchUpInside)
//        let barBtn = UIBarButtonItem(customView: btn)
        let btn = CustomBarButton(customView: btn2)
        btn.hasUnread = hasUnread
        btn.tintColor = color
        self.navigationItem.setRightBarButton(btn, animated: animated)
    }

    @objc func setInviteEmoji() {
        let btn = UIBarButtonItem(title: "👋", style: .plain, target: self, action: #selector(self.invitePeople))
//        btn.tintColor = color
        self.navigationItem.setLeftBarButton(btn, animated: false)
    }

    @objc func invitePeople() {
        let text = "👋 Join me on the Gala app! It's a new photo and video sharing app that's exclusive to the iPhone."
        let myWebsite = URL(string: "https://apps.apple.com/us/app/gala-creativity-welcomed/id1560876288")
//        let shareAll = [text , myWebsite]
        let activityViewController = UIActivityViewController(activityItems: [text, myWebsite!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @objc func setRightNavBtnText(text: String, font: UIFont = BaseFont.get(.bold, 18), color: UIColor = .systemBlue, action: Selector, animated: Bool = false) {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 34))
        btn.setTitle(text, for: [])
        btn.titleLabel?.font = font
        btn.setTitleColor(color, for: [])
        btn.addTarget(self, action: action, for: .touchUpInside)
        let barBtn = UIBarButtonItem(customView: btn)
        self.navigationItem.setRightBarButton(barBtn, animated: animated)
    }

    func setXNavBtn(color: UIColor = .label, animated: Bool = false) {
        let btn = UIBarButtonItem(image: UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))!, style: .done, target: self, action: #selector(self.dismissCurrentVC))
        btn.tintColor = color
        self.navigationItem.setLeftBarButton(btn, animated: animated)
    }

    func setBackBtn(color: UIColor = .label, animated: Bool = false) {
//        let btn = UIBarButtonItem(image: UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))!, style: .done, target: self, action: #selector(self.popVC))
        let btn = UIBarButtonItem(image: UIImage(named: "customarrowback")!, style: .done, target: self, action: #selector(self.popVC))
        btn.tintColor = color
        self.navigationItem.setLeftBarButton(btn, animated: animated)
    }

    func setPostNavItems(saveAction: Selector, shareAction: Selector, post: BMPost? = nil) {
//        var saveBtn = UIBarButtonItem(image: UIImage(systemName: "bookmark.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))!, style: .done, target: self, action: saveAction)
        var saveBtn = UIBarButtonItem(image: .get(name: "bookmark", tint: .white), style: .done, target: self, action: saveAction)
        saveBtn.tintColor = .white
//        let shareBtn = UIBarButtonItem(image: UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))!, style: .done, target: self, action: shareAction)
        var starBtn = UIBarButtonItem(image: .get(name: "staricon", tint: .white), style: .done, target: self, action: shareAction)
        starBtn.tintColor = .white
        if let p = post {
            if BMUser.me()?.checkSaved(post: p) == true {
//                saveBtn = UIBarButtonItem(image: UIImage(systemName: "bookmark.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))!, style: .done, target: self, action: saveAction)
                saveBtn = UIBarButtonItem(image: .get(name: "bookmarkfill", tint: .white), style: .done, target: self, action: saveAction)
                saveBtn.tintColor = .white
            }
            if BMUser.me()?.checkCollection(post: p) == true {
                starBtn = UIBarButtonItem(image: .get(name: "starfill", tint: .white), style: .done, target: self, action: shareAction)
                starBtn.tintColor = .white
            }

        }
        self.navigationItem.setRightBarButtonItems([saveBtn, starBtn], animated: false)
    }

    @objc func dismissCurrentVC() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func popVC() {
        self.navigationController?.popViewController(animated: true)
    }

    func menuPush(vc: UIViewController, completion: (()->Void)?) {
        self.navigationController?.pushVC(vc: vc, animated: true) {
          // Animation done
            completion?()
        }
    }

    func push(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }

    #warning("Change when new camera implemented")
    @objc func openCamera() {
        let camera = CameraViewController() //
        camera.modalPresentationStyle = .fullScreen
        self.present(camera, animated: true, completion: nil)
    }

    @objc func editAvatar() {
        addHaptic(style: .light)
        let container = ContainerController(mode: .library)
        container.libraryController.fetchPredicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue)")
        container.libraryController.draftMediaTypes = [.image]
        container.editControllerDelegate = self
        container.libraryController.previewCropController.aspectRatio = CGSize(width: 4, height: 4)
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }

    @objc func editVideo() {
        addHaptic(style: .light)
        let container = ContainerController(modes: [.library, .video], initialMode: .library)
        container.libraryController.fetchPredicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.video.rawValue)")
        container.libraryController.draftMediaTypes = [.video]
        container.editControllerDelegate = self
        container.libraryController.previewCropController.aspectRatio = CGSize(width: 4, height: 4)
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }

    func removeRedDot(index: Int) {
        for subview in tabBarController!.tabBar.subviews {

            if let subview = subview as? UIView {

                if let i = subview.accessibilityIdentifier {
                    if subview.tag == 1314 && i == "\(index)" {
                        subview.hide(duration: 0.2)
                        Timer.schedule(delay: 0.2) { timer in
                            subview.removeFromSuperview()
                        }
//                        subview.removeFromSuperview()
                        break
                    }
                }
            }
        }
    }

    func addRedDotAtTabBarItemIndex(index: Int) {

        let profileService = ClientAPI.sharedInstance.profileService
        var controller: CustomTabBarController!

        guard let c = profileService.tabController else {
            print("COULD NOT FIND TABBARCONTROLLER")
            return
        }
        controller = c

        guard  let vc = controller else {
            print("COULD NOT FIND TABBARCONTROLLER")
            return
        }

        for subview in vc.tabBar.subviews {
            if let subview = subview as? UIView {
                if subview.tag == 1314 {
                    subview.removeFromSuperview()
                    break
                }
            }
        }

        let RedDotRadius: CGFloat = 4
        let RedDotDiameter = RedDotRadius * 2

        let TopMargin:CGFloat = 8

        let TabBarItemCount = CGFloat(vc.tabBar.items!.count)

        let HalfItemWidth = view.bounds.width / (TabBarItemCount * 2)

        let  xOffset = HalfItemWidth * CGFloat(index * 2 + 1)

        let imageHalfWidth: CGFloat = (vc.tabBar.items![index] as! UITabBarItem).selectedImage!.size.width / 2

        let redDot = UIView(frame: CGRect(x: xOffset + imageHalfWidth, y: TopMargin, width: RedDotDiameter, height: RedDotDiameter))

        redDot.accessibilityIdentifier = "\(index)"
        redDot.tag = 1314
        redDot.backgroundColor = .systemRed
        redDot.layer.cornerRadius = RedDotRadius


        vc.tabBar.addSubview(redDot)
        redDot.hide(duration: 0)
        Timer.schedule(delay: 0.2) { timer in
            redDot.show(duration: 0.25)
        }
    }

    func showUserList(users: [BMUser], extra: ATAction? = nil) {
        // Action Sheet
        let actionSheet = ATActionSheet()
        var actions = [ATAction]()
        for user in users.prefix(6) {
            let action = ATAction(title: user.username!, imageUrl: user.avatar!, style: .default) {
                actionSheet.dismiss(animated: true) {
                    let vc = UserProfileViewController.makeVC(user: user)
                    self.push(vc: vc)
                }
            }
            actions.append(action)
        }

        actionSheet.addActions(actions)
        present(actionSheet, animated: true, completion: nil)
    }

    @objc func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // Hide keyboard for UIView
    @objc func hideKeyboardWhenViewTapped(v: UIView) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        v.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func updateFCMToken() {
        let token = UserDefaults.standard.string(forKey: "userDeviceFCMToken")
        if let t = token {
            PushService.make().updateFCMToken(token: t) { (response) in
                print("updated user fcm token: ", t)
            }
        } else {

        }
    }

    func statusBarHeight() -> CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            let safeFrame = window.safeAreaLayoutGuide.layoutFrame
            return safeFrame.minY - 12
        } else {
            return 0
        }
    }
}

// MARK: - Controller + Camera Delegate
extension UIViewController: EditControllerDelegate, CameraControllerDelegate {

    public func cameraController(_ cameraController: CameraController, willShowEditController editController: EditController, withSession session: Session) {
        editController.compactControls = true

    }
    
    public func editController(_ editController: EditController, didFinishEditing session: Session) {
        guard let user = BMUser.me() else { return }
        editController.presentLoadingAlertModal(animated: true, completion: nil)
        if let vid = session.video {
            VideoExporter.shared.export(video: vid, progress: { progress in
                print("Export progress: \(progress)")
            }, completion: { error in
                if let error = error {
                    print("Unable to export video: \(error)")
                    return
                }

                session.video
                
                print("Finished video export at URL: \(vid.exportedVideoURL)")
                session.video!.videoSegments.first!.requestThumbnail(boundingSize: session.video!.videoSegments.first!.naturalSize, contentMode: .contentAspectFill, filter: session.video!.videoSegments.first!.filters.first) { (img) in
                    let uploadVC = PostUploadViewController.makeVC(user: user, delegate: self, image: img, videoURL: vid.exportedVideoURL, video: session.video!)
                    editController.dismissLoadingAlertModal(animated: true) {
                        editController.push(vc: uploadVC)
                        return
                    }
                }
            })
        } else {
            ImageExporter.shared.export(image: session.image!, compressionQuality: 0.75) { (error, img) in
                let uploadVC = PostUploadViewController.makeVC(user: user, delegate: self, image: img, videoURL: nil)
                editController.dismissLoadingAlertModal(animated: true) {
                    editController.push(vc: uploadVC)
                }
            }
        }

    }
}

// MARK: - NewFeedItemDelegate
extension UIViewController: NewFeedItemDelegate {
    //created new feed item from camera
    public func createdNewItem(post: BMPost) {
        print("Added new feed item to cards")
        if let vc = self as? HomeTestViewController {
            print("Added new feed item to cards")
            vc.cardSwiper.insertCards(at: [vc.feedService.posts.count-1])
            vc.presentedViewController?.dismiss(animated: true, completion: nil)
            if let index = vc.cardSwiper.focussedCardIndex {
                _ = vc.cardSwiper.scrollToCard(at: 0, animated: true)
            }
        } else {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

func getVisibleVC(_ rootViewController: UIViewController?) -> UIViewController? {

    var rootVC = rootViewController
    if rootVC == nil {
        rootVC = UIApplication.shared.keyWindow?.rootViewController
    }

    if rootVC?.presentedViewController == nil {
        return rootVC
    }

    if let presented = rootVC?.presentedViewController {
        if presented.isKind(of: UINavigationController.self) {
            let navigationController = presented as! UINavigationController
            return navigationController.viewControllers.last!
        }

        if presented.isKind(of: UITabBarController.self) {
            let tabBarController = presented as! UITabBarController
            return tabBarController.selectedViewController!
        }

        return UIApplication.shared.getVisibleViewController(presented)
    }
    return nil
}
