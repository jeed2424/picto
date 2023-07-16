import UIKit
//import SwiftyCam
import AVKit
import PixelSDK

class PostUploadViewController: UITableViewController {
    
    @IBOutlet weak var postImgView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var locationCell: UITableViewCell!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var categoryCell: UITableViewCell!
    @IBOutlet weak var categoryLbl: UILabel!
    
    let mockService = MockService.make()
    var postImage: UIImage!
    var videoURL: URL!
    var video: SessionVideo!
    var feedDelegate: NewFeedItemDelegate?
    var post: BMPost!
    var creating: Bool = false
    var gifData: Data!
    var gifString = ""
    
//    let placeholder = "Add a 🔥 caption to this post..."
    
    static func makeVC(user: BMUser, delegate: NewFeedItemDelegate, image: UIImage?, videoURL: URL?, video: SessionVideo? = nil) -> PostUploadViewController {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "PostUploadViewController") as! PostUploadViewController
        vc.postImage = image
        vc.feedDelegate = delegate
        vc.videoURL = videoURL
        vc.video = video
        let post = BMPost(user: user, caption: "")
        let media = BMPostMedia(imageUrl: nil, videoUrl: videoURL?.absoluteString)
        post.medias.append(media)
        vc.post = post
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        postImgView.image = self.postImage ?? nil
        captionTextView.delegate = self
//        captionTextView.text = captionTextView.checkPlaceholder(placeholder: placeholder, color: .label)
        self.hideKeyboardWhenTappedAround()
        if let c = BMPostService.make().selectedCat {
//            self.categoryLbl.text = c.title!
            self.setCategory(cat: c)
        }
        self.postImgView.layer.cornerCurve = .continuous
        setNav()
        if let vid = self.video {
            if let vidSeg = vid.videoSegments.first {
                vidSeg.requestThumbnail(boundingSize: CGSize(width: 250, height: 300), contentMode: .contentAspectFill) { (img) in
                    self.postImage = img
                }
            }
            DispatchQueue.main.async {
                let temporaryFile = (NSTemporaryDirectory() as NSString).appendingPathComponent("post\(Date())")
                let fileURL = URL(fileURLWithPath: temporaryFile)
                if let i = UIImage.gifImageWithURL(fileURL.absoluteString) {
                    self.postImgView.image = i
                } else {
                    Regift.createGIFFromSource(vid.exportedVideoURL, destinationFileURL: fileURL, startTime: 0, duration: Float((2)), frameRate: 8) { (result) in
                        print("Gif saved to \(result)")
                        let imageURL = UIImage.gifImageWithURL(result!.absoluteString)
                        self.postImgView.image = imageURL!
                        let data = try! Data(contentsOf: result!)
                        self.gifData = data
                        print("gifDATA: ", data)
                        BMPostService.make().uploadToFirebaseGIF(data: self.gifData) { (gifUrl) in
                            self.gifString = gifUrl
                            print("added gif url: ", gifUrl)
                        } failure: { (error) in
                            print("error uploading gif: ", error)
                        }
//                        let asset = AVURLAsset(url: result!)
//                        asset.data
//                        asset.url.getGifImageDataFromAssetUrl(completion: { (d) in
//                            self.gifData = d
//                            print("gifDATA: ", d)
//                            BMPostService.make().uploadToFirebaseGIF(data: self.gifData) { (gifUrl) in
//                                self.gifString = gifUrl
//                                print("added gif url: ", gifUrl)
//                            } failure: { (error) in
//                                print("error uploading gif: ", error)
//                            }
//
//                        })
//                        self.gifData = URL(string: result!.absoluteString)?.getGifImageDataFromAssetUrl(completion: { (d) in
//                            <#code#>
//                        })
                    }
                }
            }
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNav()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNav()
    }
    
    func setNav() {
//        self.navigationController?.makeNavigationBarTransparent()
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.barTintColor = .systemBackground
//        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.title = "New Post"
        let postBtn = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(self.createPost))
        postBtn.tintColor = .systemBlue
                            
        navigationItem.setRightBarButton(postBtn, animated: false)
        self.setBackBtn(color: .label, animated: true)
    }
    
    @objc func createPost() {
        if self.creating == false {
            self.creating = true
            self.post!.createdAt = Date()
            self.view.endEditing(true)
            self.presentLoadingAlertModal(animated: true, completion: nil)
            BMPostService.make().createPost(post: self.post!, image: self.postImage, url: self.videoURL, gifUrl: self.gifString) { (response, p) in
                print("created new post")
//                spinner.dismiss()
                self.dismissLoadingAlertModal(animated: true, completion: {
                    if let po = p {
                        self.createdNewPost(post: po)
                    } else {
                        self.creating = false
                    }
                })
            }
        }
    }
    
    func createdNewPost(post: BMPost) {
        addHaptic(style: .success)
        if let d = self.feedDelegate {
            self.navigationController?.popToRootViewController(animated: true)
         //   ProfileService.make().user!.posts.insert(post, at: 0)
            d.createdNewItem(post: post)
        }
    }
    
}

extension PostUploadViewController: PostCategoryDelegate, PostLocationDelegate {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return self.locationCell
        case 1: return self.categoryCell
        default:
            let cell = UITableViewCell()
            cell.separatorInset.left = screenWidth
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.push(vc: PostLocationViewController.makeVC(delegate: self))
        } else if indexPath.row == 1 {
            self.push(vc: PostCategoryViewController.makeVC(delegate: self))
        }
    }
    
    func setCategory(cat: BMCategory) {
        self.post!.category = cat
        self.categoryLbl.text = cat.title!
    }
    
    func setLocation(location: String) {
        self.post!.location = location
        self.locationLbl.text = location
    }
}

extension PostUploadViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
//        self.captionTextView.text = self.captionTextView.checkPlaceholder(placeholder: placeholder, color: .label)
//        if self.captionTextView.text! != self.placeholder {
//            self.post!.caption = self.captionTextView.text!
//        } else {
//            self.post!.caption = ""
//        }
        self.post!.caption = self.captionTextView.text!
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        if self.captionTextView.text! == self.placeholder {
//            self.captionTextView.text = ""
//        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
//        self.captionTextView.text = self.captionTextView.checkPlaceholder(placeholder: self.placeholder, color: .label)
    }
}

import UIKit
import Photos

extension URL {
    func getGifImageDataFromAssetUrl(completion: @escaping(_ imageData: Data?) -> Void) {
        let asset = PHAsset.fetchAssets(withALAssetURLs: [self], options: nil)
        if let image = asset.firstObject {
            PHImageManager.default().requestImageData(for: image, options: nil) { (imageData, _, _, _) in
                completion(imageData)
            }
        }
    }
}
