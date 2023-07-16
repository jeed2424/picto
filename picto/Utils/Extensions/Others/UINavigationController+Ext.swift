import Foundation
import UIKit

extension UINavigationController {

  public func pushVC(vc: UIViewController,
                                 animated: Bool,
                                 completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    pushViewController(vc, animated: animated)
    CATransaction.commit()
  }

}
