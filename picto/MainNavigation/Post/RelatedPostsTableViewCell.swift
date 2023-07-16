//
//  RelatedPostsTableViewCell.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/16/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit

class RelatedPostsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 200, height: 250)
            layout.minimumInteritemSpacing = 15
            layout.minimumLineSpacing = 15
            layout.scrollDirection = .horizontal
            layout.sectionInset.left = 20
            layout.sectionInset.right = 20
            layout.sectionInset.bottom = 10
            collectionView.collectionViewLayout = layout
            collectionView.showsHorizontalScrollIndicator = false
        }
    }
    
}

import SDWebImage

class RelatedPostCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: SDAnimatedImageView!
    @IBOutlet weak var vidIcon: UIImageView!
    
    var post: BMPost!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView.image = nil
        self.post = nil
        self.vidIcon.alpha = 0
    }
    
    func setPost(post: BMPost) {
        self.post = post
        self.vidIcon.alpha = 0
        self.vidIcon.image = .get(name: "videoicon", tint: .white)
        if post.contentType() == .video {
            self.vidIcon.alpha = 0
//            if let url = self.post!.medias.first!.imageUrl {
//                self.imgView.setImage(string: url)
//            } else {
//                self.imgView.setThumbnail(string: self.post!.medias.first!.videoUrl!)
//            }
//            if let url = self.post!.medias.first!.imageUrl {
//                self.imgView.setImage(string: url)
//            } else {
//                self.imgView.setThumbnail(string: self.post!.medias.first!.videoUrl!)
//            }
            if let v = post.medias.first!.videoUrl {
                if let videoURL = URL(string: v) {
//                    self.imgView.image = UIImage.gifImageWithData(AVU)
                    let frameCount = 16
                    let delayTime  = Float(0)
                    let loopCount  = 0    // 0 means loop forever

//                    DispatchQueue.main.async {
//                        let temporaryFile = (NSTemporaryDirectory() as NSString).appendingPathComponent("post\(post.id!)")
                    let media = post.medias.first!
//                    if let image = media.image {
//                        self.imgView.image = image
////                        self.videoPlayer.setPlayerNil()
//                    } else if let imgURL = media.imageUrl {
//                        self.imgView.setImage(string: imgURL)
////                        self.videoPlayer.setPlayerNil()
//                    }
                    
                    if let g = media.gifUrl {
                        self.imgView.setAnimatedImage(string: g)
//                        self.img
//                        if let i = UIImage.gifImageWithURL(g) {
//                            DispatchQueue.main.async {
//                                self.imgView.image = i
//                            }
////                            self.imgView.image = i
//                        }
                    } else if let imgURL = media.imageUrl {
                        self.imgView.setImage(string: imgURL)
//                        self.videoPlayer.setPlayerNil()
                    } else {
                        let temporaryFile = (NSTemporaryDirectory() as NSString).appendingPathComponent("post_\(v.replacingOccurrences(of: "/storage.googleapis.com/emblem_creator_videos/", with: "").replacingOccurrences(of: "/firebasestorage.googleapis.com/v0/b/warbly-265ed.appspot.com/o/videos%", with: "").replacingOccurrences(of: "/", with: ""))")
                        let fileURL = URL(fileURLWithPath: temporaryFile)
                        if let i = UIImage.gifImageWithURL(fileURL.absoluteString) {
                            self.imgView.image = i
                        } else {
                            DispatchQueue.main.async {
                                Regift.createGIFFromSource(videoURL, destinationFileURL: fileURL, startTime: 0, duration: 2, frameRate: 2, size: self.imgView.frame.size) { (result) in
                                    print("Gif saved to \(result)")
                                    //                let gifURL : String = "http://www.gifbin.com/bin/4802swswsw04.gif"
                                    let imageURL = UIImage.gifImageWithURL(result!.absoluteString)
                                    self.imgView.image = imageURL!
                                }
                            }
                        }
                    }
//                    let temporaryFile = (NSTemporaryDirectory() as NSString).appendingPathComponent("post_\(v.replacingOccurrences(of: "/storage.googleapis.com/emblem_creator_videos/", with: "").replacingOccurrences(of: "/firebasestorage.googleapis.com/v0/b/warbly-265ed.appspot.com/o/videos%", with: "").replacingOccurrences(of: "/", with: ""))")
//                        let fileURL = URL(fileURLWithPath: temporaryFile)
//                        if let i = UIImage.gifImageWithURL(fileURL.absoluteString) {
//                            self.imgView.image = i
//                        } else {
//                            DispatchQueue.main.async {
//                                Regift.createGIFFromSource(videoURL, destinationFileURL: fileURL, startTime: 0, duration: 2, frameRate: 2, size: self.imgView.frame.size) { (result) in
//                                    print("Gif saved to \(result)")
//                                    //                let gifURL : String = "http://www.gifbin.com/bin/4802swswsw04.gif"
//                                    let imageURL = UIImage.gifImageWithURL(result!.absoluteString)
//                                    self.imgView.image = imageURL!
//                                }
//                            }
//                        }
//                    }
                }
            } else {
                if let url = self.post!.medias.first!.imageUrl {
                    self.imgView.setImage(string: url)
                } else {
                    self.imgView.setThumbnail(string: self.post!.medias.first!.videoUrl!)
                }
            }
        } else if let url = self.post!.medias.first!.imageUrl {
            self.imgView.setImage(string: url)
        }
        self.imgView.layer.cornerCurve = .continuous
    }
    
}

