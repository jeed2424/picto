import Foundation
import UIKit

extension UICollectionView {
    func fadeReload(duration: Double = 0.15) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve) {
            self.reloadData()
        } completion: { (completed) in
        }
    }
}
