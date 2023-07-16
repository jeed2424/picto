import Combine
import Foundation

/// A collection of cancellables that can be managed in a bunch
public class CompositeCancellable: Cancellable {

    /// The cancellables
    private var cancellables: [Cancellable] = []

    /// Utility operating to make it more palatble
    public static func += (left: CompositeCancellable, cancellable: Cancellable) {
        left.cancellables.append(cancellable)
    }

    /// Initializer
    public init() {}

    /// Deinit
    deinit {
        cancel()
    }

    /// Cancel
    public func cancel() {
        let currentCancellables = Array(cancellables)
        cancellables.removeAll()
        for cancellable in currentCancellables {
            cancellable.cancel()
        }
    }
}

public extension Cancellable {

    /// Utility method to make RxSwift porting easier
    func disposed(by: CompositeCancellable) {
        by += self
    }
}
