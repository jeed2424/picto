import Foundation

public extension DispatchQueue {
    /// A bunch of predefined queue for reuse
    class Predefined {
        /// For background tasks
        public static let background = DispatchQueue.global(qos: .background)

        /// For Low-Priority Task
        public static let low = DispatchQueue.global(qos: .utility)

        /// For High Priority Task
        public static let high = DispatchQueue.global(qos: .userInitiated)

        /// For Highest Priority Task
        public static let animation = DispatchQueue.global(qos: .userInteractive)

        /// For Regular Task
        public static let normal = DispatchQueue.global(qos: .default)

        /// For the UI / Main Thread
        public static let ui = DispatchQueue.main
    }

    /// Synchronous call on the main thread
    class func syncUI(_ handler: @escaping () -> Void) {
        RunLoop.main.perform {
            handler()
        }
    }

    /// Asynchronous Call after X seconds
    func asyncAfter(_ duration: Int,
                    action: @escaping () -> Void) {
        asyncAfter(deadline: .now() + .seconds(duration), execute: action)
    }
}
