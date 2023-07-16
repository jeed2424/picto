//
//  CustomCameraViewController.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/10/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit
import AVFoundation

class CustomCameraViewController: UIImagePickerController {
    
    var feedDelegate: NewFeedItemDelegate?
    
    init(feedDelegate: NewFeedItemDelegate) {
        self.feedDelegate = feedDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
