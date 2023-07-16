////
////  PlayerView.swift
////  InstagramFirestoreTutorial
////
////  Created by Stephen Dowless on 2/11/21.
////  Copyright © 2021 Stephan Dowless. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//
//class PlayerView: UIView {
//    
//    // MARK: - Properties
//    
//    var player: AVPlayer? {
//        get { return playerLayer.player }
//        set { playerLayer.player = newValue }
//    }
//    
//    var feedItem: FeedItem!
//    var post: BMPost!
//    var videoUrl: String!
//    var videoViewDelegate: VideoViewDelegate?
//    var playOnLoad: Bool = false
//    
//    var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
//    
//    private var playerItemContext = 0
//    private var playerItem: AVPlayerItem?
//    
//    // MARK: - Lifecycle
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
////    required init?(coder: NSCoder) {
////        fatalError("init(coder:) has not been implemented")
////    }
//    
//    override class var layerClass: AnyClass {
//        return AVPlayerLayer.self
//    }
//    
//    deinit {
//        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        playerLayer.frame = self.frame
//        playerLayer.videoGravity = .resizeAspectFill
//    }
//    
//    // MARK: - Helpers
//    
//    func play(_ url: URL) {
//        configureAsset(withUrl: url) { asset in
//            self.configurePlayerItem(withAsset: asset)
//        }
//    }
//    
//    private func configurePlayerItem(withAsset asset: AVAsset) {
//        if let p = self.playerItem {
//            
//        } else {
//            self.playerItem = AVPlayerItem(asset: asset)
//            self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status),
//                                         options: [.old, .new], context: &self.playerItemContext)
//            
//            DispatchQueue.main.async {
//                self.player = AVPlayer(playerItem: self.playerItem!)
//                NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
//            }
//        }
//    }
//    
//    private func configureAsset(withUrl url: URL, completion: ((AVAsset) -> Void)?) {
//        let asset = AVAsset(url: url)
//        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
//            var error: NSError? = nil
//            let status = asset.statusOfValue(forKey: "playable", error: &error)
//            
//            switch status {
//            case .loaded:
//                completion?(asset)
//            case .failed:
//                print("DEBUG: Failed to load asset")
//            case .cancelled:
//                print("DEBUG: Cancelled")
//            default: break
//            }
//        }
//    }
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        // Only handle observations for the playerItemContext
//        guard context == &playerItemContext else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//            return
//        }
//            
//        if keyPath == #keyPath(AVPlayerItem.status) {
//            let status: AVPlayerItem.Status
//            if let statusNumber = change?[.newKey] as? NSNumber {
//                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
//            } else {
//                status = .unknown
//            }
//            // Switch over status value
//            switch status {
//            case .readyToPlay:
//                print(".readyToPlay")
//                if self.playOnLoad == true {
//                    self.player?.play()
//                }
//                if let item  = self.post {
//                    print("increased view count")
//                    item.viewCount += 1
//                    BMPost.save(post: &self.post!)
//                    if let d = self.videoViewDelegate {
//                        d.addViewCount(post: item)
//                    }
//                }
//            case .failed:
//                print(".failed")
//            case .unknown:
//                print(".unknown")
//            @unknown default:
//                print("@unknown default")
//            }
//        }
//    }
//    
//    @objc func playerItemDidReachEnd(_ notification: NSNotification) {
//        if self.player != nil {
//            self.player!.seek(to: CMTime.zero)
//            self.player!.play()
//            if let item  = self.post {
//                print("increased view count")
//                item.viewCount += 1
//                if let d = self.videoViewDelegate {
//                    d.addViewCount(post: item)
//                }
//            }
//        }
//    }
//}
