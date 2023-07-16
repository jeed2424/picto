//
//  ATTAlertViewControllerButton.swift
//  TwitterAlertController
//
//  Created by Ammar AlTahhan on 10/12/2018.
//  Copyright © 2018 Ammar AlTahhan. All rights reserved.
//

import UIKit

public class ATAction: UIView {
    
    private let leftButtonPadding: CGFloat = 25
    private let imageViewWidth: CGFloat = 38
    private let interImageTitleSpace: CGFloat = 20
    
    private var button = UIButton()
    private var imageView = UIImageView()
    
    private var onTapCompletion: (() -> Void)?
    private var isCancelButton: Bool
    private var _style: ATAction.Style
    
    public override var bounds: CGRect {
        didSet {
            if isCancelButton {
                layer.cornerRadius = frame.height/2
                layer.masksToBounds = true
            }
        }
    }
    public var style: ATAction.Style { return _style }
    
    // MARK: - Initializers
    
    private override init(frame: CGRect) {
        isCancelButton = false
        onTapCompletion = nil
        _style = .default
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(title: String, image: UIImage? = nil, style: ATAction.Style = .default, completion: @escaping () -> Void) {
        self.init()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = BaseFont.get(.medium, 16)
        imageView.image = image
        onTapCompletion = completion
        isCancelButton = false
        _style = style
        setupView()
    }
    
    public convenience init(title: String, imageUrl: String, style: ATAction.Style = .default, completion: @escaping () -> Void) {
        self.init()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = BaseFont.get(.medium, 16)
        imageView.setImage(string: imageUrl)
        onTapCompletion = completion
        isCancelButton = false
        _style = style
        setupView()
    }
    
    convenience init(title: String, completion: @escaping () -> Void) {
        self.init()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = BaseFont.get(.bold, 15)
        onTapCompletion = completion
        isCancelButton = true
        setupView()
    }
    
    // MARK: - Setups
    
    private func setupView() {
//        button.setTitleColor(style == .default ? .ATTextColor : .ATDestructiveColor, for: .normal)
        button.setTitleColor(style == .default ? .label : .systemRed, for: .normal)
        if style == .link {
            button.setTitleColor(.systemBlue, for: .normal)
        }
        addSubview(button)
        setButtonConstraints()
        if !isCancelButton {
            setupNotCancelView()
        } else {
            setupCancelButton()
        }
        if isCancelButton {
            if traitCollection.userInterfaceStyle == .light {
                button.setTitleColor(.white, for: .normal)
            } else {
                button.setTitleColor(.black, for: .normal)
            }
        }
        
        setButtonAction()
    }
    
    private func setupCancelButton() {
        if traitCollection.userInterfaceStyle == .light {
            backgroundColor = .black
        } else {
            backgroundColor = .white
        }
    }
    
    private func setupNotCancelView() {
        if #available(iOS 11.0, *) {
            button.contentHorizontalAlignment = .leading
        } else {
            button.contentHorizontalAlignment = .left
        }
        button.imageView?.contentMode = .scaleAspectFill
        imageView.contentMode = .scaleAspectFill
//        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
//        imageView.tintColor = style == .default ? .ATImageTintColor : .ATDestructiveColor
        addSubview(imageView)
        bringSubviewToFront(button)
        setImageViewConstraints()
        if imageView.image == nil {
            button.titleEdgeInsets = UIEdgeInsets(top: -10, left: 0, bottom: 10, right: 0)
        } else {
//            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: leftButtonPadding + imageViewWidth + interImageTitleSpace, bottom: 0, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: leftButtonPadding + interImageTitleSpace + 10, bottom: 0, right: 0)
        }
    }
    
    private func setButtonConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        if isCancelButton {
//            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
//            button.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        }
    }
    
    private func setImageViewConstraints() {
        if imageView.image != nil {
            imageView.translatesAutoresizingMaskIntoConstraints = false
//            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftButtonPadding).isActive = true
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//            imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//            imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//            imageView.center(inView: self)
//            imageView.widthAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
//            imageView.heightAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
    }
    
    private func setButtonAction() {
        button.addTarget(self, action: #selector(self.buttonAction(_:)), for: .touchUpInside)
    }
    
    @objc private func buttonAction(_ sender: Any) {
        onTapCompletion?()
    }
    
}
