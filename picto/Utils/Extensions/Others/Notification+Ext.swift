import Combine
import Foundation

public extension Notification.Name {

    /// Subscribe to specified notification
    func publisher(for object: AnyObject? = nil) -> NotificationCenter.Publisher {
        NotificationCenter.Publisher(center: .default, name: self, object: object)
    }

    /// Post a notification
    func post(queue: DispatchQueue = DispatchQueue.Predefined.ui,
              async: Bool = true,
              object: Any? = nil) {
        let handler: () -> Void = {
            NotificationCenter.default.post(name: self, object: object)
        }

        if async {
            queue.async(execute: handler)
        } else {
            queue.sync(execute: handler)
        }
    }

    /// Post a notification
    func post(userInfo: [AnyHashable: Any],
              queue: DispatchQueue = DispatchQueue.Predefined.ui,
              async: Bool = true,
              object: Any? = nil) {
        let handler: () -> Void = {
            NotificationCenter.default.post(name: self, object: object, userInfo: userInfo)
        }

        if async {
            queue.async(execute: handler)
        } else {
            queue.sync(execute: handler)
        }
    }

    /// Register to this notification using selector
    func register(_ observer: Any,
                  selector: Selector,
                  object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: self, object: object)
    }

    /// Register to this notification using an operation queue
    func register(object: Any? = nil,
                  queue: OperationQueue = OperationQueue.main,
                  handler: @escaping (Notification) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: self, object: object, queue: queue, using: handler)
    }

    /// Unregister from this notification
    func unregister(_ observer: Any, object: Any? = nil) {
        NotificationCenter.default.removeObserver(observer, name: self, object: object)
    }

    /// Unregister observer from all notifications
    static func unregister(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
}
