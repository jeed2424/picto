//
//  ExpandableTableView.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/16/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit

@objcMembers open class ExpandingTableView: UITableView, UIScrollViewDelegate {
    
//    fileprivate weak var expyDataSource: ExpyTableViewDataSource?
    fileprivate weak var expandingDataSource: ExpandingTableViewDataSource?
    fileprivate weak var expandingDelegate: ExpandingTableViewDelegate?
    
    public fileprivate(set) var expandedSections: [Int: Bool] = [:]
    
      open var expandingAnimation: UITableView.RowAnimation = ExpandingTableViewDefaultValues.expandingAnimation
      open var collapsingAnimation: UITableView.RowAnimation = ExpandingTableViewDefaultValues.collapsingAnimation
    
      public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override var dataSource: UITableViewDataSource? {
        
        get { return super.dataSource }
        
        set(dataSource) {
            guard let dataSource = dataSource else { return }
            expandingDataSource = dataSource as? ExpandingTableViewDataSource
            super.dataSource = self
        }
    }
    
    open override var delegate: UITableViewDelegate? {
        
        get { return super.delegate }
        
        set(delegate) {
            guard let delegate = delegate else { return }
            expandingDelegate = delegate as? ExpandingTableViewDelegate
            super.delegate = self
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        if expandingDelegate == nil {
            //Set UITableViewDelegate even if ExpandingTableViewDelegate is nil. Because we are getting callbacks here in didSelectRowAtIndexPath UITableViewDelegate method.
            super.delegate = self
        }
    }
}

extension ExpandingTableView {
    public func expand(_ section: Int) {
        animate(with: .expand, forSection: section)
    }
    
    public func collapse(_ section: Int) {
        animate(with: .collapse, forSection: section)
    }
    
    private func animate(with type: ExpandingActionType, forSection section: Int) {
        guard canExpand(section) else { return }
        
        let sectionIsExpanded = didExpand(section)
        
        //If section is visible and action type is expand, OR, If section is not visible and action type is collapse, return.
        if ((type == .expand) && (sectionIsExpanded)) || ((type == .collapse) && (!sectionIsExpanded)) { return }
        
        assign(section, asExpanded: (type == .expand))
        startAnimating(self, with: type, forSection: section)
    }
    
    private func startAnimating(_ tableView: ExpandingTableView, with type: ExpandingActionType, forSection section: Int) {
    
        let headerCell = (self.cellForRow(at: IndexPath(row: 0, section: section)))
        let headerCellConformant = headerCell as? ExpandingTableViewHeaderCell
        
        CATransaction.begin()
        headerCell?.isUserInteractionEnabled = false
        
        //Inform the delegates here.
        headerCellConformant?.changeState((type == .expand ? .willExpand : .willCollapse), cellReuseStatus: false)
        expandingDelegate?.tableView(tableView, expandingState: (type == .expand ? .willExpand : .willCollapse), changeForSection: section)

        CATransaction.setCompletionBlock {
            //Inform the delegates here.
            headerCellConformant?.changeState((type == .expand ? .didExpand : .didCollapse), cellReuseStatus: false)
            
            self.expandingDelegate?.tableView(tableView, expandingState: (type == .expand ? .didExpand : .didCollapse), changeForSection: section)
            headerCell?.isUserInteractionEnabled = true
        }
        
        self.beginUpdates()
        
        //Don't insert or delete anything if section has only 1 cell.
        if let sectionRowCount = expandingDataSource?.tableView(tableView, numberOfRowsInSection: section), sectionRowCount > 1 {
            
            var indexesToProcess: [IndexPath] = []
            
            //Start from 1, because 0 is the header cell.
            for row in 1..<sectionRowCount {
                indexesToProcess.append(IndexPath(row: row, section: section))
            }
            
            //Expand means inserting rows, collapse means deleting rows.
            if type == .expand {
                self.insertRows(at: indexesToProcess, with: expandingAnimation)
            }else if type == .collapse {
                self.deleteRows(at: indexesToProcess, with: collapsingAnimation)
            }
        }
        self.endUpdates()
        
        CATransaction.commit()
    }
}

extension ExpandingTableView: UITableViewDataSource {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = expandingDataSource?.tableView(self, numberOfRowsInSection: section) ?? 0
        
        guard canExpand(section) else { return numberOfRows }
        guard numberOfRows != 0 else { return 0 }
        
        return didExpand(section) ? numberOfRows : 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard canExpand(indexPath.section), indexPath.row == 0 else {
            return expandingDataSource!.tableView(tableView, cellForRowAt: indexPath)
        }
        
        let headerCell = expandingDataSource!.tableView(self, expandableCellForSection: indexPath.section)
        
        guard let headerCellConformant = headerCell as? ExpandingTableViewHeaderCell else {
            return headerCell
        }
        
        DispatchQueue.main.async {
            if self.didExpand(indexPath.section) {
                headerCellConformant.changeState(.willExpand, cellReuseStatus: true)
                headerCellConformant.changeState(.didExpand, cellReuseStatus: true)
            }else {
                headerCellConformant.changeState(.willCollapse, cellReuseStatus: true)
                headerCellConformant.changeState(.didCollapse, cellReuseStatus: true)
            }
        }
        return headerCell
    }
}

extension ExpandingTableView: UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        expandingDelegate?.tableView?(tableView, didSelectRowAt: indexPath)
        
        guard canExpand(indexPath.section), indexPath.row == 0 else { return }
        didExpand(indexPath.section) ? collapse(indexPath.section) : expand(indexPath.section)
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        expandingDelegate?.didScroll(contentOffset: scrollView.contentOffset.y)
    }
}

//MARK: Helper Methods

extension ExpandingTableView {
    fileprivate func canExpand(_ section: Int) -> Bool {
        //If canExpandSections delegate method is not implemented, it defaults to true.
        return expandingDataSource?.tableView(self, canExpandSection: section) ?? ExpandingTableViewDefaultValues.expandableStatus
    }
    
    fileprivate func didExpand(_ section: Int) -> Bool {
        return expandedSections[section] ?? false
    }
    
    fileprivate func assign(_ section: Int, asExpanded: Bool) {
        expandedSections[section] = asExpanded
    }
}

//MARK: Protocol Helper
extension ExpandingTableView {
    fileprivate func verifyProtocol(_ aProtocol: Protocol, contains aSelector: Selector) -> Bool {
        return protocol_getMethodDescription(aProtocol, aSelector, true, true).name != nil || protocol_getMethodDescription(aProtocol, aSelector, false, true).name != nil
    }
    
    override open func responds(to aSelector: Selector!) -> Bool {
        if verifyProtocol(UITableViewDataSource.self, contains: aSelector) {
            return (super.responds(to: aSelector)) || (expandingDataSource?.responds(to: aSelector) ?? false)
            
        }else if verifyProtocol(UITableViewDelegate.self, contains: aSelector) {
            return (super.responds(to: aSelector)) || (expandingDelegate?.responds(to: aSelector) ?? false)
        }
        return super.responds(to: aSelector)
    }
    
    override open func forwardingTarget(for aSelector: Selector!) -> Any? {
        if verifyProtocol(UITableViewDataSource.self, contains: aSelector) {
            return expandingDataSource
            
        }else if verifyProtocol(UITableViewDelegate.self, contains: aSelector) {
            return expandingDelegate
        }
        return super.forwardingTarget(for: aSelector)
    }
}

public struct ExpandingTableViewDefaultValues {
    public static let expandableStatus = true
      public static let expandingAnimation: UITableView.RowAnimation = .fade
      public static let collapsingAnimation: UITableView.RowAnimation = .fade
}

@objc public enum ExpandingState: Int {
    case willExpand, willCollapse, didExpand, didCollapse
}

public enum ExpandingActionType {
    case expand, collapse
}

@objc public protocol ExpandingTableViewHeaderCell: class {
    func changeState(_ state: ExpandingState, cellReuseStatus cellReuse: Bool)
}

@objc public protocol ExpandingTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: ExpandingTableView, canExpandSection section: Int) -> Bool
    func tableView(_ tableView: ExpandingTableView, expandableCellForSection section: Int) -> UITableViewCell
}

@objc public protocol ExpandingTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: ExpandingTableView, expandingState state: ExpandingState, changeForSection section: Int)
    func didScroll(contentOffset: CGFloat)
}

