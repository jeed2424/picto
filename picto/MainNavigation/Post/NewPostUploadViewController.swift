import UIKit
import Foundation
import DropDown
import AVKit
import CameraManager

class NewPostUploadViewController: KeyboardManagingViewController {

    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 20

        stack.axis = .vertical
        stack.alignment = .center

        return stack
    }()

    private lazy var postImgView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var categorySelectionMenu: DropDown = {
        let menu = DropDown()
        menu.translatesAutoresizingMaskIntoConstraints = false

        menu.dataSource = categories

        return menu
    }()

    private lazy var categorySelectionView: DropDownView = {
        let view = DropDownView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.title.text = "Select Category"

        return view
    }()

    //    private lazy var LocationSelection: DropDown = {
    //        let menu = DropDown()
    //        menu.translatesAutoresizingMaskIntoConstraints = false
    //
    //        menu.dataSource = categories
    //
    //        return menu
    //    }()

    private lazy var captionTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    // MARK: - Variables
    private var categories: [String] = []

    let mockService = MockService.make()
    var postImage: UIImage!
    var videoURL: URL!
    var video: URL?
    var feedDelegate: NewFeedItemDelegate?
    var post: BMPost!
    var creating: Bool = false
    var gifData: Data!
    var gifString = ""

    //    let placeholder = "Add a 🔥 caption to this post..."

    init(user: BMUser, delegate: NewFeedItemDelegate, image: UIImage?, videoURL: URL?, video: URL? = nil) {
        super.init()
        let vc = self
        vc.postImage = image
        vc.feedDelegate = delegate
        vc.videoURL = videoURL
        vc.video = video
        let post = BMPost(user: user, caption: "")
        let media = BMPostMedia(imageUrl: nil, videoUrl: videoURL?.absoluteString)
        post.medias.append(media)
        vc.post = post
//        return vc
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCategories()
        postImgView.image = self.postImage ?? nil
        captionTextView.delegate = self
        self.hideKeyboardWhenTappedAround()
//        if let c = BMPostService.make().selectedCat {
//            //            self.categoryLbl.text = c.title!
//            self.setCategory(cat: c)
//        }
        self.postImgView.layer.cornerCurve = .continuous
        setNav()
        addGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNav()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNav()
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

extension NewPostUploadViewController: PostCategoryDelegate, PostLocationDelegate {

    func setCategory(cat: BMCategory) {
        self.post!.category = cat
        //   self.categoryLbl.text = cat.title!
    }

    func setLocation(location: String) {
        //        self.post!.location = location
        //        self.locationLbl.text = location
    }
}

extension NewPostUploadViewController: UITextViewDelegate {

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

// MARK: - UI
extension NewPostUploadViewController {
    private func setupStyle() {
        keyboardManagingScrollView = scrollView
        defaultkeyboardManagingScrollViewContentInset = scrollView.contentInset

        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            vStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            vStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        vStack.addArrangedSubviews([
            postImgView,
            categorySelectionView,
            captionTextView
        ])

        NSLayoutConstraint.activate([
            postImgView.widthAnchor.constraint(equalToConstant: 160),
            postImgView.heightAnchor.constraint(equalToConstant: 160)
        ])
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
}
// MARK: - Functions
extension NewPostUploadViewController {
    private func getCategories() {
        ProfileService.make().categories.forEach { category in
            categories.append(category.title)
        }
    }
}

// MARK: - Actions
extension NewPostUploadViewController {
    @objc func didTapDropDown() {
        categorySelectionMenu.show()
    }
}

// MARK: - Gestures
extension NewPostUploadViewController {
    private func addGestures() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapDropDown))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        categorySelectionView.addGestureRecognizer(tap)
    }
}


//import UIKit
//import Photos
//
//extension URL {
//    func getGifImageDataFromAssetUrl(completion: @escaping(_ imageData: Data?) -> Void) {
//        let asset = PHAsset.fetchAssets(withALAssetURLs: [self], options: nil)
//        if let image = asset.firstObject {
//            PHImageManager.default().requestImageData(for: image, options: nil) { (imageData, _, _, _) in
//                completion(imageData)
//            }
//        }
//    }
//}
