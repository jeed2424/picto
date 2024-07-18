import UIKit
import Foundation
import DropDown
import AVKit
import CameraManager
import SupabaseManager

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

        menu.dataSource = categoriesTitles

        menu.direction = .bottom
        
        menu.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }

            if let category = categories.first(where: { $0.title == item }) {
                self.setCategory(cat: category)
            }
            print("Selected item: \(item) at index: \(index)")
        }
        
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
        
        view.placeholder = "Caption"
        
        view.font = .systemFont(ofSize: 16)
        
        view.borderWidth = 1
        view.borderColor = .black

        return view
    }()

    // MARK: - Variables
    private var categoriesTitles: [String] = []
    private var categories: [BMCategory] = []

    let mockService = MockService.make()
    var postImage: UIImage?
    var videoURL: URL?
    var video: URL?
    var feedDelegate: NewFeedItemDelegate?
    var post: BMPost?
    var creating: Bool = false
    var gifData: Data?
    var gifString = ""

    //    let placeholder = "Add a 🔥 caption to this post..."

    static func makeVC(user: BMUser, delegate: NewFeedItemDelegate, image: UIImage?, videoURL: URL?, video: URL? = nil) -> NewPostUploadViewController {
//        super.init()
        let vc = NewPostUploadViewController()
        vc.postImage = image
        vc.feedDelegate = delegate
//        vc.videoURL = videoURL
//        vc.video = video
        let post = BMPost(identifier: nil, user: user, caption: "")
//        let media = BMPostMedia(imageUrl: nil, videoUrl: videoURL?.absoluteString)
//        post.medias.append(media)
        vc.post = post
        return vc
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
        setupStyle()
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
            
            let data = self.postImage?.jpegData(compressionQuality: 0.5)
            
            //        self.avatar.image = image
            //        self.avatarDidChange = true
            //        self.avatarData = data
            
            let storageManager = SupabasePostStorageManager.sharedInstance
            let databaseManager = SupabaseDatabaseManager.sharedInstance
            
            let user = BMUser.me()
            
            let dbUser: DbUser = DbUser(id: user?.identifier ?? UUID(), username: user?.username ?? "", firstName: user?.firstName ?? "", lastName: user?.lastName ?? "", email: user?.email ?? "", bio: user?.bio ?? "", website: user?.website ?? "", showFullName: user?.showName ?? false, avatar: user?.avatar ?? "", posts: BMUser.me()?.getPostIDs() ?? [])
            storageManager.uploadPost(user: self.post?.user?.identifier, image: data, completion: { imageUrl in
                if let imageUrl = imageUrl {
                    
                    let post = DbPost(identifier: nil, createdAt: Date.now.toYearMonthDay(), owner: user?.identifier ?? UUID(), image: imageUrl, comments: [], likeCount: 0)
                    databaseManager.uploadPost(user: dbUser, post: post, completion: { newPost in
                        print("\(newPost?.identifier)")
                    })
                    
                }
            })
            //                        try await databaseManager.uploadPost(user: <#T##DbUser#>, post: <#T##DbPost#>, completion: <#T##(PostObject?) -> ()#>)
            //                    })
            //            }
            //            BMPostService.make().createPost(post: self.post!, image: self.postImage, url: self.videoURL, gifUrl: self.gifString) { (response, p) in
            //                print("created new post")
            //                //                spinner.dismiss()
            //                self.dismissLoadingAlertModal(animated: true, completion: {
            //                    if let po = p {
            //                        self.createdNewPost(post: po)
            //                    } else {
            //                        self.creating = false
            //                    }
            //                })
            //            }
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
        self.post?.category = cat
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
        self.post?.caption = self.captionTextView.text ?? ""
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
            vStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 25),
            vStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -25),
            vStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            vStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        vStack.addArrangedSubviews([
            postImgView,
            categorySelectionView,
//            categorySelectionMenu,
            captionTextView
        ])

        NSLayoutConstraint.activate([
            postImgView.widthAnchor.constraint(equalToConstant: 160),
            postImgView.heightAnchor.constraint(equalToConstant: 160),
            captionTextView.heightAnchor.constraint(equalToConstant: 250),
            captionTextView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 50)
        ])
        
        vStack.setCustomSpacing(50, after: categorySelectionMenu)
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
        ProfileService.sharedInstance.categories.forEach { category in
            if let title = category.title {
                categories.append(category)
                categoriesTitles.append(title)
            }
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

extension NewPostUploadViewController {
    private func uploadPost() {
        
    }

    private func saveUser(user: BMUser?) {
        guard let user = user else { return }
        let authManager = SupabaseAuthenticationManager.sharedInstance
        let profileService = ProfileService.sharedInstance
        let authService = AuthenticationService.sharedInstance

//        var postID: [Int] = {
//            var anything: [Int] = []
//            for i in 0..<user.posts.count {
//                let post = user.posts[i]
//
//                if let postID = post.postID {
//                    anything.append(postID)
//                }
//
//                if i == user.posts.count - 1 {
//                    return anything
//                } else {
//                    continue
//                }
//            }
//        }()

        print("Hello saveUser: \(user.avatar)")
        let dbUser = DbUser(id: user.identifier ?? UUID(), username: user.username ?? "", firstName: user.firstName ?? "", lastName: user.lastName ?? "", email: user.email ?? "", bio: user.bio ?? "", website: user.website ?? "", showFullName: user.showName, avatar: user.avatar ?? "", posts: user.getPostIDs() ?? [])
        print("Hello DBUser: \(dbUser.avatar)")

        authManager.updateUser(user: dbUser, completion: {[weak self] updatedUser in
            guard let self = self else { return }
            if let updatedUser = updatedUser{
//                self.auth.authenticationSuccess(user: usr)
//                if let user = manager.authenticatedUser {
                let userUpdate = BMUser(id: updatedUser.id, username: updatedUser.username, firstName: updatedUser.firstName, lastName: updatedUser.lastName, email: updatedUser.email, bio: updatedUser.bio, website: updatedUser.website, showFullName: updatedUser.showFullName, avatar: updatedUser.avatar, posts: [])
                    profileService.updateUser(user: userUpdate)
                    authService.saveUpdatedUser(user: userUpdate)
                    self.dismissLoadingAlertModal(animated: true) {
                        self.popVC()
                    }
//                }
            }
        })

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
