//
//  CustomTextField.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 6/22/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    init(placeholder: String, imageName: String) {
        super.init(frame: .zero)
        
        let spacer = UIView()
        spacer.setDimensions(height: 50, width: 4)
        let imageView = UIImageView(image: UIImage(systemName: imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.setDimensions(height: 24, width: 24)
        imageView.tintColor = .init(white: 1, alpha: 0.7)
        
        let stack = UIStackView(arrangedSubviews: [spacer, imageView])
        stack.spacing = 8
        
        leftView = stack
        leftViewMode = .always
        
        borderStyle = .roundedRect
        textColor = .white
        keyboardAppearance = .dark
        keyboardType = .emailAddress
        backgroundColor = UIColor(white: 1, alpha: 0.1)
        setHeight(50)
        attributedPlaceholder = NSAttributedString(string: placeholder,
                                                   attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        
        let clearButton : UIButton = self.value(forKey: "_clearButton") as! UIButton
        let image = UIImage(systemName: "xmark.circle.fill")
        clearButton.tintColor = .white
        clearButton.setImage(image, for: .normal)
        clearButton.backgroundColor = UIColor.clear
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
