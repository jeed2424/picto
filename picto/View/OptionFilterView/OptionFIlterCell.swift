//
//  OptionFIlterCell.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 3/1/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit

class OptionFIlterCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var option: OptionFilterViewModel! {
        didSet { titleLabel.text = option.description }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primaryTextColor
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Test Filter"
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            titleLabel.font = isSelected ? UIFont.boldSystemFont(ofSize: 16) :
                UIFont.systemFont(ofSize: 16)
        }
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundColor
        
        addSubview(titleLabel)
        titleLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
