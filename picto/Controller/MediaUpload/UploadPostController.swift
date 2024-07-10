////
////  UploadPostController.swift
////  InstagramFirestoreTutorial
////
////  Created by Stephen Dowless on 8/31/20.
////  Copyright © 2020 Stephan Dowless. All rights reserved.
////
//import UIKit
//
//protocol UploadPostControllerDelegate: class {
//    func controllerDidFinishUploadingPost(_ controller: UploadPostController)
//}
//
//enum UploadConfiguration {
//    case newPost
//    case edit(Post)
//    
//    var navigationItemTitle: String {
//        switch self {
//        case .newPost: return "Upload Post"
//        case .edit: return "Edit Post"
//        } 
//    }
//}
//
//class UploadPostController: UIViewController {
//    
//    // MARK: - Properties
//    
//    private let config: UploadConfiguration
//    weak var delegate: UploadPostControllerDelegate?
//        
//    var selectedImage: UIImage? {
//        didSet { photoImageView.image = selectedImage }
//    }
//    
//    var currentUser: User?
//    
//    private let photoImageView: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFill
//        iv.clipsToBounds = true
//        return iv
//    }()
//    
//    private lazy var captionTextView: InputTextView = {
//        let tv = InputTextView()
//        tv.placeholderText = "Enter caption.."
//        tv.font = UIFont.systemFont(ofSize: 16)
//        tv.delegate = self
//        tv.placeholderShouldCenter = false
//        return tv
//    }()
//    
//    private let characterCountLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .lightGray
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.text = "0/100"
//        return label
//    }()
//    
//    // MARK: - Lifecycle
//    
//    init(config: UploadConfiguration) {
//        self.config = config
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//    }
//    
//    // MARK: - API
//    
//    func uploadPost(withCaption caption: String) {
//        guard let image = selectedImage else { return }
//        guard let user = currentUser else { return }
//        showLoader(true)
//        
//        PostService.uploadPost(caption: caption, image: image, user: user) { error in
//            self.showLoader(false)
//
//            if let error = error {
//                self.showMessage(withTitle: "Error", message: error.localizedDescription)
//                return
//            }
//            
//            self.delegate?.controllerDidFinishUploadingPost(self)
//        }
//    }
//    
//    func updatePost(_ post: Post, withCaption caption: String) {
//        guard caption != post.caption else {
//            self.showMessage(withTitle: "Error", message: "It looks like you didnt change anything")
//            return
//        }
//        
//        showLoader(true)
//        PostService.updatePost(post, newCaption: caption) { _ in
//            self.showLoader(false)
//            self.delegate?.controllerDidFinishUploadingPost(self)
//        }
//    }
//    
//    // MARK: - Actions
//    
//    @objc func didTapCancel() {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    @objc func didTapDone() {
//        guard let caption = captionTextView.text else { return }
//        
//        switch config {
//        case .newPost:
//            uploadPost(withCaption: caption)
//        case .edit(let post):
//            updatePost(post, withCaption: caption)
//        }
//    }
//    
//    // MARK: - Helpers
//    
//    func loadPostDataIfNecessary() {
//        if case .edit(let post) = config {
//            photoImageView.sd_setImage(with: URL(string: post.imageUrl))
//            captionTextView.text = post.caption
//            captionTextView.placeholderLabel.isHidden = true
//            characterCountLabel.text = "\(post.caption.count)/100"
//        }
//    }
//    
//    func configureUI() {
//        view.backgroundColor = .white
//        navigationItem.title = config.navigationItemTitle
//        
//        loadPostDataIfNecessary()
//        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
//                                                           target: self,
//                                                           action: #selector(didTapCancel))
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done,
//                                                            target: self, action: #selector(didTapDone))
//        
//        view.addSubview(photoImageView)
//        photoImageView.setDimensions(height: 180, width: 180)
//        photoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
//        photoImageView.centerX(inView: view)
//        photoImageView.layer.cornerRadius = 10
//        
//        view.addSubview(captionTextView)
//        captionTextView.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor,
//                               right: view.rightAnchor, paddingTop: 16, paddingLeft: 12,
//                               paddingRight: 12, height: 64)
//        
//        view.addSubview(characterCountLabel)
//        characterCountLabel.anchor(bottom: captionTextView.bottomAnchor, right: view.rightAnchor,
//                                   paddingBottom: -8, paddingRight: 12)
//    }
//}
//
//// MARK: - UITextViewDelegate
//extension UploadPostController: UITextViewDelegate {
//    func textViewDidChange(_ textView: UITextView) {
//        textView.checkMaxLength()
//        let count = textView.text.count
//        characterCountLabel.text = "\(count)/100"
//    }
//}
