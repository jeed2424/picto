//
//  AppDelegate.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 5/27/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
//import FirebaseAnalytics
import UserNotifications
import SDWebImage
import AVFoundation
import SwiftyBeaver
import ObjectMapper
import PixelSDK
//import Delighted
import GoogleSignIn
import AppTrackingTransparency
import SupabaseManager

let log = SwiftyBeaver.self

// mobile-sdk-FyS0rWudJOXsuJjE

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = NSUUID().uuidString
    
    var showMessageNoti: Bool = true

    var supabaseManager = SupabaseManager.sharedInstance
    var authManager = SupabaseAuthenticationManager.sharedInstance

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
//        GIDSignIn.sharedInstance.clientID = FirebaseApp.app()?.options.clientID
//        GIDSignIn.sharedInstance.delegate = self
        Messaging.messaging().delegate = self

        SDImageCache.shared.config.shouldCacheImagesInMemory = true
        SDImageCache.shared.config.diskCacheReadingOptions = .mappedIfSafe
        SDImageCache.shared.config.shouldRemoveExpiredDataWhenEnterBackground = false
        SDImageCache.shared.config.maxDiskAge = -1

        attemptToRegisterForNotifications(application: application)

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: .mixWithOthers)
        } catch let error {
            print(error.localizedDescription)
        }
        
//        ObjectLoader.shared.cache.removeAll()
        
        PixelSDK.setup("bHsiayI6InFmQyROYDFsbUtSRi1eOm5RZyIsInYiOiJmOEZEaiIsImkiOiIzOSJ9OHBB")
        // Set the maximum video duration to 1 minute.
        PixelSDK.shared.maxVideoDuration = 60*1
        
//        Delighted.initializeSDK()

        setupRootViewController()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
//        Delighted.initializeSDK()
      }
        
    func attemptToRegisterForNotifications(application: UIApplication) {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (authorized, _) in
            if authorized {
                print("DEBUG: SUCCESSFULLY REGISTERED FOR NOTIFICATIONS")
            }
        }
        
        application.registerForRemoteNotifications()
    }

//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
    
    func reloadAppToMain() {
        self.setupRootViewController()
    }
    
    func extractUserInfo(userInfo: [AnyHashable : Any]) -> (title: String, body: String, text: String, name: String, pic: String) {
        var info = (title: "", body: "", text: "", name: "", pic: "")
        guard let aps = userInfo["aps"] as? [String: Any] else { return info }
        guard let alert = aps["alert"] as? [String: Any] else { return info }
        let title = alert["title"] as? String ?? ""
        let body = alert["body"] as? String ?? ""
        let text = userInfo["text"] as? String ?? ""
        let name = userInfo["from_user_username"] as? String ?? ""
        let pic = userInfo["from_user_avatar"] as? String ?? ""
        info = (title: title, body: body, text: text, name: name, pic: pic)
        return info
    }
    
    func parseMessage(userInfo: [AnyHashable : Any]) -> (BMMessage?) {
        guard let aps = userInfo["aps"] as? [String: Any] else { return nil }
        guard let alert = aps["alert"] as? [String: Any] else { return nil }
        let title = alert["title"] as? String ?? ""
        if title.contains("New message from ") {
            print("GALA MESSAGE: ", userInfo["gala_message"]!)
            let message = String(describing: userInfo["gala_message"]!)
            let data = Data(message.utf8)

            do {
                // make sure this JSON is in the format we expect
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a string array
//                    if let names = json["names"] as? [String] {
//                        print(names)
//                    }
                    return MessageSerializer.unserialize(JSON: json)
                } else {
                    return nil
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                return nil
            }
        } else {
            return nil
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
//        print("PUSH INFO HASH: ", self.parseMessage(userInfo: userInfo))
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
//        print("PUSH INFO FETCH COMPLETION: ", self.parseMessage(userInfo: userInfo))

      completionHandler(UIBackgroundFetchResult.newData)
    }

}

extension AppDelegate: MessagingDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("DEBUG: Registered for notifications with device token: ", deviceToken)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("DEBUG: Registered with FCM Token: ", fcmToken)
        Messaging.messaging().retrieveFCMToken(forSenderID: "1033756784306") { (tok, error) in
//            print("FCM ERROR: ", error)
//            print("GOOD TOKEN: ", tok)
            if let t = tok {
                UserDefaults.standard.setValue(t, forKey: "userDeviceFCMToken")
            }
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
      // ...
      if let error = error {
        // ...
          print("\(error.localizedDescription)")
        return
      }

//       let authentication = user //.authentication
    //    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken ?? "",
    //                                                    accessToken: authentication.accessToken)
      // ...
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
//    print("PUSH INFO WILL PRESENT: ", self.parseMessage(userInfo: userInfo))

//    // Change this to your preferred presentation option
      if self.parseMessage(userInfo: userInfo) != nil {
//        if var convo = me.conversations.first(where: {$0.id! == message.convoId!}) {
//            convo.messages.append(message)
//            convo.lastMessage = message
//            BMConversation.save(convo: &convo)
//            BMMessage.save(message: &message)
//            NotificationCenter.default.post(name: NSNotification.Name("newMessageReceived"), object: nil)
//        } else {
//            print("this is from a new convo you don't have yet")
//            completionHandler([[.alert, .sound]])
//        }
//        if self.showMessageNoti == true {
//            completionHandler([[.alert, .sound]])
//        } else {
//            completionHandler([[]])
//        }
//        completionHandler([[]])
//    } else {
        completionHandler([[.sound]])
    }
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
//    print(userInfo)
    print("PUSH INFO DID RECEIVE: ", self.extractUserInfo(userInfo: userInfo))

    completionHandler()
  }
}

extension UIApplication {

    var visibleVC: UIViewController? {

        guard let rootViewController = keyWindow?.rootViewController else {
            return nil
        }

        return getVisibleViewController(rootViewController)
    }

    func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {

        if let presentedViewController = rootViewController.presentedViewController {
            return getVisibleViewController(presentedViewController)
        }

        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }

        if let tabBarController = rootViewController as? UITabBarController {
            return tabBarController.selectedViewController
        }

        return rootViewController
    }
}

extension UIApplication {
//    class func topVC(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
//        if let navigationController = controller as? UINavigationController {
//            return topVC(controller: navigationController.visibleViewController)
//        }
//        if let tabController = controller as? UITabBarController {
//            if let selected = tabController.selectedViewController {
//                return topVC(controller: selected)
//            }
//        }
//        if let presented = controller?.presentedViewController {
//            return topVC(controller: presented)
//        }
//        return controller
//    }
    
}

func topVC() -> UIViewController? {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        // topController should now be your topmost view controller
        return topController
    }
    return nil
}

func topVC(type: UIViewController.Type) -> UIViewController? {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            if topController.isKind(of: type) {
                print("IS KIND OF: ", type)
                topController = presentedViewController
            }
        }

        // topController should now be your topmost view controller
        return topController
    }
    return nil
}

protocol GalaMessageDelegate {
    func didReceiveMessage(message: BMMessage)
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}

class CustomBarButton: UIBarButtonItem {
    // Unread Mark
    private var unreadMark: CAShapeLayer?

    // Keep track of unread status
    var hasUnread: Bool = false {
        didSet {
            setUnread(hasUnread: hasUnread)
        }
    }

    // Toggles unread status
    private func setUnread(hasUnread: Bool) {
        if hasUnread {
            unreadMark = CAShapeLayer()
            unreadMark?.path = UIBezierPath(ovalIn: CGRect(x: (self.customView?.frame.width ?? 0) - 10, y: 0, width: 10, height: 10)).cgPath
            unreadMark?.fillColor = UIColor.red.cgColor
            self.customView?.layer.addSublayer(unreadMark!)
        } else {
            unreadMark?.removeFromSuperlayer()
        }

    }
}

extension AppDelegate {
    private func setupRootViewController() {
        self.authManager.currentUser(completion: { [weak self] user in
            guard let self = self else { return }

            if let user = user {
                let databaseManager = SupabaseDatabaseManager.sharedInstance
                var posts: [BMPost]? = []

                let bmUser = BMUser(id: user.id, username: user.username, firstName: user.firstName, lastName: user.lastName, email: user.email, bio: user.bio, website: user.website, showFullName: user.showFullName, avatar: user.avatar, posts: [])

                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now(), execute: {
                    databaseManager.fetchUserPosts(user: user.id, completion: { userPosts in
                        posts = userPosts?.compactMap({ post in BMPost(identifier: post.identifier,
                                                                       createdAt: post.createdAt?.dateAndTimeFromString(),
                                                                       user: bmUser,
                                                                       caption: post.caption,
                                                                       location: "",
                                                                       category: nil,
                                                                       commentCount: post.commentCount,
                                                                       likeCount: post.likeCount,
                                                                       comments: nil,
                                                                       medias: {
                            post.images?.compactMap({ image in BMPostMedia(imageUrl: image, videoUrl: nil) })
                        }()
                        )})
                    })

                    if let posts = posts {
                        bmUser.posts = posts
                    }

                    let auth = AuthenticationService.make()
                    auth.authenticationSuccess(user: bmUser)
                    ProfileService.sharedInstance.saveUser(user: bmUser)

                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        self.presentMain(user: bmUser)
                    })
                })
            } else {
                DispatchQueue.main.async {
                    let center = NewHomeViewController()

                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    self.window?.rootViewController = center
                    self.window?.tintColor = .white
                    self.window?.makeKeyAndVisible()
                }
            }
        })
    }

    private func presentMain(user: BMUser) {
        
        print("POSTS: \(user.posts.count)")

        for post in user.posts {
            print("POST: \(post.user?.identifier)")
        }
        
        let feed = FeedService.make()
//        feed.getFeed(all: true) { (response, posts) in
//            feed.posts = posts
            let tabBarController = CustomTabBarController()
            let home = HomeTestViewController.makeVC()
            let base1 = self.createVC(vc: home, icon: UIImage(named: "homeicon1")!.withTintColor(.systemGray), selected: UIImage(named: "homeicon1-selected")!)
//            let search = SearchController(config: .all)
            let base2 = self.createVC(vc: DiscoverViewController.makeVC(), icon: UIImage(named: "searchicon")!.withTintColor(.systemGray), selected: UIImage(named: "searchicon-selected")!)
            let base3 = self.createVC(vc: UserNotificationsViewController.makeVC(), icon: UIImage(named: "notificationbell")!.withTintColor(.systemGray), selected: UIImage(named: "notificationbell-selected")!)
            if let profile = UserProfileViewController.makeVC(user: user, fromTab: true) {
                let base4 = self.createVC(vc: profile, icon: UIImage(named: "profileicon")?.withTintColor(.systemGray) ?? UIImage(), selected: UIImage(named: "profileicon-selected") ?? UIImage())
                tabBarController.viewControllers = [base1, base2, base3, base4]
                showTabBar(tabBarController)
            } else {
                tabBarController.viewControllers = [base1, base2, base3]
                showTabBar(tabBarController)
            }
//        }
    }

    private func createVC(vc: UIViewController, icon: UIImage, selected: UIImage) -> BaseNC {
        let nc = BaseNC(rootViewController: vc)
        nc.tabBarItem = UITabBarItem(title: "", image: icon, tag: 0)
        nc.tabBarItem.selectedImage = selected
        return nc
    }

    private func showTabBar(_ tabBarController: UITabBarController) {
        tabBarController.tabBar.tintColor = .label
        tabBarController.tabBar.barTintColor = .systemBackground
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.shadowImage = UIImage()
        tabBarController.tabBar.backgroundImage = UIImage()
        tabBarController.modalPresentationStyle = .fullScreen
        tabBarController.view.backgroundColor = .systemBackground
        tabBarController.modalTransitionStyle = .crossDissolve
        ProfileService.sharedInstance.tabController = tabBarController

        window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = tabBarController
        window?.tintColor = .white
        window?.makeKeyAndVisible()
    }
}
