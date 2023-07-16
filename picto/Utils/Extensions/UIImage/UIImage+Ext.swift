import Foundation
import UIKit
import Photos
import PixelSDK
import SDWebImage
import AVKit
import AVFoundation

extension UIImageView {
    func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
        self.layer.masksToBounds = true
        //        self.mask = self.superview
        self.clipsToBounds = true
    }
    
    @objc
    private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else {
            //            UIApplication.shared.keyWindow!.bringSubviewToFront(sender.view!)
            return
        }
        sender.view?.transform = scale
        sender.scale = 1
    }
    
    func round() {
        self.layer.cornerCurve = .continuous
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.size.height * 0.425
    }
    
    func setImage(string: String, placeholderImg: UIImage? = nil) {
        if let url = URL(string: string) {
            self.sd_imageTransition = .fade(duration: 0.15)
            self.sd_setImage(with: url, placeholderImage: placeholderImg, options: [.highPriority, .queryMemoryDataSync], context: nil)
            //            self.sd_setImage(with: url, placeholderImage: placeholderImg ?? nil)
        }
    }
    
    
    func setImage(string: String, placeholderImg: UIImage? = nil, duration: Double = 0.3, completion: ((UIImage)->Void)!) {
        if let url = URL(string: string) {
            self.sd_imageTransition = .fade(duration: 0.15)
            //            let t = SDImageCacheType.all
            self.sd_setImage(with: url) { (img, erro, t, u) in
                if erro != nil {
                    self.sd_setImage(with: url) { (img, erro, t, u) in
                        completion!(img ?? UIImage())
                    }
                } else {
                    completion!(img!)
                }
            }
        }
    }
    
    func getImage(string: String, placeholderImg: UIImage? = nil, duration: Double = 0.3, completion: ((UIImage)->Void)!) {
        if let url = URL(string: string) {
            self.sd_imageTransition = .fade(duration: 0.15)
            //            let t = SDImageCacheType.all
            self.sd_setImage(with: url) { (img, erro, t, u) in
                if erro != nil {
                    self.sd_setImage(with: url) { (img, erro, t, u) in
                        completion!(img ?? UIImage())
                    }
                } else {
                    completion!(img!)
                }
            }
        }
    }
    
    func setThumbnail(string: String) {
        let vidURL = URL(string: string)!
        AVAsset(url: vidURL).makeThumbnail { [weak self] (image) in
            DispatchQueue.main.async {
                guard let image = image else { return }
                UIView.transition(with: self!, duration: 0.3, options: .transitionCrossDissolve) {
                    self!.image = image
                } completion: { (completed) in
                    
                }
            }
        }
    }
}
