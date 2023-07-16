import Foundation
import UIKit

extension UITableView {

    func sizeHeaderToFit(preferredWidth: CGFloat) {
        guard let headerView = self.tableHeaderView else {
            return
        }

        headerView.translatesAutoresizingMaskIntoConstraints = false
        let layout = NSLayoutConstraint(
            item: headerView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute:
                .notAnAttribute,
            multiplier: 1,
            constant: preferredWidth)

        headerView.addConstraint(layout)

        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.frame = CGRect(x: 0, y: 0, width: preferredWidth, height: height)

        headerView.removeConstraint(layout)
        headerView.translatesAutoresizingMaskIntoConstraints = true
        self.reloadData()
        self.tableHeaderView = headerView
    }

    func fadeReload(duration: Double = 0.15) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve) {
            self.reloadData()
        } completion: { (completed) in
        }
    }

    func scrollToBottom(){

        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }

    func scrollToBottomNoAnim(){

        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .middle, animated: false)
            }
        }
    }

    func scrollToTop() {

        DispatchQueue.main.async {
            self.setContentOffset(.zero, animated: true)
        }
    }

    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}
