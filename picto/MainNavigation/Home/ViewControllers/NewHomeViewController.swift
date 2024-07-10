import Foundation
import UIKit
import Foil
import Combine
import SkyFloatingLabelTextField
import Firebase
import SupabaseManager

class NewHomeViewController: UIViewController {

    // MARK: - Variables
    private(set) var viewModel = ViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = [AnyCancellable]()


    // MARK: - UI Components

    private lazy var googleLogin = GoogleLoginView()
    private lazy var emailLogin = EmailLoginView()
    private lazy var registerView = RegisterView()
    private lazy var usernameView = UsernameCreationView()

    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16

        return stack
    }()

    private lazy var appLogo: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = R.image.picto()?.resize(CGSize(width: 240, height: 240))

        return view
    }()

    private lazy var welcomeMessage: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to your new favorite app!"
        label.font = .systemFont(ofSize: 24)

        return label
    }()

    private lazy var subtitleMessage: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Have fun out here!"
        label.font = .systemFont(ofSize: 14)

        return label
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0

        return view
    }()

    private lazy var registerAccount: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("Register an Account", for: .normal)
        button.setTitleColor(.black, for: .normal)

        button.backgroundColor = .systemBlue

        button.addTarget(self, action: #selector(goToRegister(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var orLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = "Or"
        label.textColor = .label

        return label
    }()

    private lazy var loginWithGoogle: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("SignIn with Google", for: .normal)
        button.setTitleColor(.black, for: .normal)

        button.backgroundColor = .systemBlue

        button.addTarget(self, action: #selector(goToGoogle(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var loginWithEmail: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("SignIn with Email", for: .normal)
        button.setTitleColor(.black, for: .normal)

        button.backgroundColor = .systemRed

        button.addTarget(self, action: #selector(goToEmail(_:)), for: .touchUpInside)

        return button
    }()

    override func viewDidLoad() {
        setupViews()
        bindViewModel()
        setObservers()
    }
}

// MARK: - UI
extension NewHomeViewController {
    private func setupViews() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundColor

        view.addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            vStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 105),
            vStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -55)
        ])

        vStack.addArrangedSubviews([
            appLogo,
            welcomeMessage,
            activityIndicator,
            subtitleMessage,
            registerAccount,
            orLabel,
            loginWithGoogle,
            loginWithEmail
        ])

        NSLayoutConstraint.activate([
            appLogo.widthAnchor.constraint(equalToConstant: 240),
            appLogo.heightAnchor.constraint(equalToConstant: 240)
        ])
    }
}

// MARK: - Actions
extension NewHomeViewController {
    @objc func goToRegister(_ sender: UIButton) {
        viewModel.loadPageSelection(selection: .register)
    }

    @objc func goToGoogle(_ sender: UIButton) {
        viewModel.loadPageSelection(selection: .google)
    }

    @objc func goToEmail(_ sender: UIButton) {
        viewModel.loadPageSelection(selection: .email)
    }

    @objc func goToHome(_ sender: UIButton) {
        viewModel.loadPageSelection(selection: .home)
    }
}

// MARK: - Functions
extension NewHomeViewController {
    private func setCurrentPage() {

        switch self.viewModel.currentPage {

        case .home:
            if !view.subviews.isEmpty {
                for view in self.view.subviews {
                    if view != vStack {
                        view.removeFromSuperview()
                    }
                }
            }
           // setupViews()

        case .register:
            if !view.subviews.isEmpty {
                for view in self.view.subviews {
                    if view != vStack {
                        view.removeFromSuperview()
                    }
                }
            }
            addNewView(registerView)

        case .google:
            if !view.subviews.isEmpty {
                for view in self.view.subviews {
                    if view != vStack {
                        view.removeFromSuperview()
                    }
                }
            }
            addNewView(googleLogin)

        case .email:
            if !view.subviews.isEmpty {
                for view in self.view.subviews {
                    if view != vStack {
                        view.removeFromSuperview()
                    }
                }
            }
            addNewView(emailLogin)

        case .username:
            if !view.subviews.isEmpty {
                for view in self.view.subviews {
                    if view != vStack {
                        view.removeFromSuperview()
                    }
                }
            }
            addNewView(usernameView)
        }
    }

    private func addNewView(_ newView: UIView) {

        view.addSubview(newView)

        NSLayoutConstraint.activate([
            newView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newView.topAnchor.constraint(equalTo: view.topAnchor),
            newView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }

    func presentMain() {
        let feed = FeedService.make()
//        feed.getFeed(all: true) { (response, posts) in
//            feed.posts = posts
            let tabBarController = CustomTabBarController()
            let home = HomeTestViewController.makeVC()
            let base1 = self.createVC(vc: home, icon: UIImage(named: "homeicon1")!.withTintColor(.systemGray), selected: UIImage(named: "homeicon1-selected")!)
            //            let search = SearchController(config: .all)
            let base2 = self.createVC(vc: DiscoverViewController.makeVC(), icon: UIImage(named: "searchicon")!.withTintColor(.systemGray), selected: UIImage(named: "searchicon-selected")!)
            let base3 = self.createVC(vc: UserNotificationsViewController.makeVC(), icon: UIImage(named: "notificationbell")!.withTintColor(.systemGray), selected: UIImage(named: "notificationbell-selected")!)
        if let user = BMUser.me() {
            let profile = UserProfileViewController.makeVC(user: user, fromTab: true)
            let base4 = self.createVC(vc: profile, icon: UIImage(systemName: "pencil.circle")!.withTintColor(.systemGray), selected: UIImage(systemName: "pencil.circle.fill")!)
            tabBarController.viewControllers = [base1, base2, base3, base4]
        } else {
            tabBarController.viewControllers = [base1, base2, base3]
        }
            tabBarController.tabBar.tintColor = .label
            tabBarController.tabBar.barTintColor = .systemBackground
            tabBarController.tabBar.isTranslucent = false
            tabBarController.tabBar.shadowImage = UIImage()
            tabBarController.tabBar.backgroundImage = UIImage()
            tabBarController.modalPresentationStyle = .fullScreen
            tabBarController.view.backgroundColor = .systemBackground
            tabBarController.modalTransitionStyle = .crossDissolve
            ProfileService.make().tabController = tabBarController
            self.present(tabBarController, animated: true, completion: nil)
//        }
    }

    private func createVC(vc: UIViewController, icon: UIImage, selected: UIImage) -> BaseNC {
        vc.tabBarItem = UITabBarItem(title: "", image: icon, tag: 0)
        vc.tabBarItem.selectedImage = selected
        let nc = BaseNC(rootViewController: vc)
        return nc
    }

    private func createVCNav(vc: UIViewController, icon: UIImage, selected: UIImage) -> UINavigationController {
        vc.tabBarItem = UITabBarItem(title: "", image: icon, tag: 0)
        vc.tabBarItem.selectedImage = selected
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
}

// MARK: - Binding
extension NewHomeViewController {
    private func bindViewModel() {
        viewModel.$currentPage
            .subscribeOnMain()
            .receiveOnMain()
            .sink {[weak self] _ in
                self?.setCurrentPage()
            }.store(in: &cancellables)
    }
}

// MARK: - Notifications
extension NewHomeViewController {
    private func setObservers() {
        NotificationCenter.default.publisher(for: NotificationNames.dismissViewToHome)
                    .receiveOnMain()
                    .sink { [weak self] _ in
                        guard let self = self else { return }

                        self.viewModel.resetPaging()
                        self.view.layoutIfNeeded()
                    }
                    .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: NotificationNames.willShowUsernameSelection)
                    .receiveOnMain()
                    .sink { [weak self] newUser in
                        guard let self = self, let newUser = newUser.object as? BMUser, let identifier = newUser.identifier else { return }

                        self.usernameView.setValues(userId: identifier, firstName: newUser.firstName, lastName: newUser.lastName, email: newUser.email)
                        self.viewModel.loadPageSelection(selection: .username)
                    }
                    .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: NotificationNames.didRegister)
                    .receiveOnMain()
                    .sink { [weak self] usr in
                        print("\(usr.object)")
                        guard let self = self else { return }
                        guard let newUser = usr.object as? BMUser else { return }

                        self.viewModel.resetPaging()
                        self.view.layoutIfNeeded()
                        self.activityIndicator.alpha = 1
                        self.activityIndicator.startAnimating()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.alpha = 0
                            
                            let base = BaseNC(rootViewController: RegisterProfileViewController.makeVC(user: newUser))
                            base.modalPresentationStyle = .overFullScreen
                            self.present(base, animated: true, completion: nil)
//                            self.presentMain()
                        }
                    }
                    .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: NotificationNames.didLogin)
                    .receiveOnMain()
                    .sink { [weak self] usr in
                        guard let self = self else { return }
                        guard let user = usr.object as? BMUser else { return }

                        self.viewModel.resetPaging()
                        self.view.layoutIfNeeded()
                        self.activityIndicator.alpha = 1
                        self.activityIndicator.startAnimating()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.alpha = 0
//                            let base = BaseNC(rootViewController: RegisterProfileViewController.makeVC(user: user))
//                            base.modalPresentationStyle = .overFullScreen
//                            self.present(base, animated: true, completion: nil)
                            self.presentMain()
                            print("Logged in in newhome")
                        }
                    }
                    .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: NotificationNames.failedToGetUsr)
                    .receiveOnMain()
                    .sink { [weak self] _ in
                        guard let self = self else { return }

                        self.viewModel.resetPaging()
                        self.view.layoutIfNeeded()
                        self.activityIndicator.alpha = 1
                        self.activityIndicator.startAnimating()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.alpha = 0
                            self.presentMain()
                        }
                    }
                    .store(in: &subscriptions)
    }
}
