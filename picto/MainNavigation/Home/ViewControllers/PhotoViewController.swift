//
//  PhotoViewController.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/9/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit
//import SwiftyCam

class PhotoViewController: UIViewController {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let mockService = MockService.make()
    var feedDelegate: NewFeedItemDelegate?

    private var backgroundImage: UIImage

    init(image: UIImage) {
        self.backgroundImage = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.frame.size = CGSize(width: screenWidth, height: screenHeight)
        backgroundImageView.frame.origin = CGPoint(x: 0, y: 0)
        backgroundImageView.contentMode = UIView.ContentMode.scaleAspectFill
        backgroundImageView.image = backgroundImage
        view.addSubview(backgroundImageView)
        
        self.setNavTitle(text: "Photo Post", font: BaseFont.get(.bold, 18), letterSpacing: 0.1, color: .white)
        self.setXNavBtn(color: .white, animated: true)
        self.setRightNavBtn(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))!, color: .white, action: #selector(self.createPhotoPost), animated: false)
        self.mockService.createNewFeedItem(image: backgroundImage, videoUrl: nil) { (response) in
            print("Created new photo feed item")
        }
    }
    
    @objc func createPhotoPost() {
        addHaptic(style: .success)
        if let d = self.feedDelegate {
//            d.createdNewItem()
        }
        dismiss(animated: true, completion: nil)
    }

    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
