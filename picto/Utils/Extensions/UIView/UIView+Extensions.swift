//
//  UIView+Extensions.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/9/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
//            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
            return layer.cornerRadius
        }
        set {
//            layer.cornerRadius = newValue
            layer.masksToBounds = true
            layer.cornerRadius = newValue
//            return self.layer.cornerRadius
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            self.layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }


    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }

    // Animate view opacity in/out
    func hide(duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
        })
    }
    
    func show(duration: TimeInterval) {
        self.isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: { _ in
        })
    }
    
    public enum GradientType {
        case vertical
        case horizontal
        case cross
    }
    
    public func applyGradient(colors: [UIColor], type: GradientType) {
        var endPoint: CGPoint!
        switch (type) {
        case .horizontal:
            endPoint = CGPoint(x: 1, y: 0)
        case .vertical:
            endPoint = CGPoint(x: 0, y: 1)
        case .cross:
            endPoint = CGPoint(x: 1, y: 1)
        }
        self.layoutIfNeeded()
        var gradientLayer = CAGradientLayer()
        gradientLayer.backgroundColor = UIColor.black.withAlphaComponent(0.00001).cgColor
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius
        gradientLayer.colors = colors.map{ $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = endPoint
        //        self.layer.addSublayer(gradientLayer)
        let add = self.layer.sublayers?.filter {
            if $0.backgroundColor == UIColor.black.withAlphaComponent(0.00001).cgColor {
                return true
            }
            return false
        }
        if add != nil {
            if add!.isEmpty {
                self.layer.insertSublayer(gradientLayer, at: 0)
            }
        } else {
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    func addShadow(_ color: UIColor = UIColor.black.withAlphaComponent(0.15), offset: CGSize = CGSize(width: 0, height: 0), blur: CGFloat = 8) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = blur
        self.layer.shadowOpacity = 1
        self.layer.masksToBounds = false
    }

    @objc func hideKeyboard() {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.dismissKeyboard))
            tap.cancelsTouchesInView = false
            addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        endEditing(true)
    }
}

extension SDAnimatedImageView {
    func setAnimatedImage(string: String, placeholderImg: UIImage? = nil) {
        if let url = URL(string: string) {
            self.sd_imageTransition = .fade(duration: 0.15)
            self.autoPlayAnimatedImage = true
//            self.playbackMode = .
            self.sd_setImage(with: url, placeholderImage: placeholderImg, options: [.highPriority, .queryMemoryDataSync], context: nil)
//            self.sd_setImage(with: url, placeholderImage: placeholderImg ?? nil)
        }
    }
}

import AVKit
import AVFoundation

extension AVAsset {

    func makeThumbnail(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let imageGenerator = AVAssetImageGenerator(asset: self)
            let time = CMTime(seconds: 0.5, preferredTimescale: 600)
            let times = [NSValue(time: time)]
            imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, image, _, _, _ in
                if let image = image {
                    completion(UIImage(cgImage: image))
                } else {
                    completion(nil)
                }
            })
        }
    }
}
