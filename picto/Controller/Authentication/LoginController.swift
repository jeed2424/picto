//
//  LoginController.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 6/22/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import UIKit
import FacebookLogin
import Firebase
import GoogleSignIn

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete()
}

class LoginController: UIViewController {
    
    // MARK: - Properties
    let auth = AuthenticationService.make()
    
    private let loginManager = LoginManager()
    private var viewModel = LoginViewModel()
    weak var delegate: AuthenticationDelegate?
    
    private let iconImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Email", imageName: "envelope")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Password", imageName: "lock")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var facebookLoginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Continue with Facebook", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(handleFacebookLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var googleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue with Google", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Forgot your password?", secondPart: "Get help signing in.")
        button.addTarget(self, action: #selector(handleShowResetPassword), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Don't have an account?", secondPart: "Sign Up")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    // MARK: - Actions
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        AuthService.logUserIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Failed to log user in \(error.localizedDescription)")
                return
            }
            
            self.delegate?.authenticationDidComplete()
        }
    }
    
    @objc func handleFacebookLogin() {
        let permissions = ["public_profile", "email", "user_photos"]
        
        loginManager.logIn(permissions: permissions, from: self) { result, error in
            guard let token = AccessToken.current?.tokenString else { return }
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            self.showLoader(true)
            
            AuthService.loginWithFacebook(credential) { uid, shouldCreateUsername, error in
                self.showLoader(false)
                if let error = error {
                    self.showMessage(withTitle: "Error", message: error.localizedDescription)
                    return
                }
                
                if shouldCreateUsername {
                    guard let uid = uid else { return }
                    let controller = UsernameController(uid: uid)
                    controller.delegate = self.delegate
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    self.delegate?.authenticationDidComplete()
                }
            }
        }
    }
    
    @objc func handleGoogleLogin() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        
        updateForm()
    }
    
    @objc func handleShowResetPassword() {
        let controller = ResetPasswordController()
        controller.delegate = self
        controller.email = emailTextField.text
        navigationController?.pushViewController(controller, animated: true)
    }
        
    // MARK: - Helpers
    
    func configureUI() {
        
        view.backgroundColor = UIColor.black
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField,
                                                   loginButton, forgotPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        let orLabel = UILabel()
        orLabel.text = "OR"
        orLabel.textColor = .init(white: 1, alpha: 0.7)

        view.addSubview(orLabel)
        orLabel.centerX(inView: view, topAnchor: stack.bottomAnchor, paddingTop: 16)
        
        view.addSubview(facebookLoginButton)
        facebookLoginButton.anchor(top: orLabel.bottomAnchor, paddingTop: 24)
        facebookLoginButton.centerX(inView: view)
        facebookLoginButton.setDimensions(height: 50, width: 360)
        facebookLoginButton.layer.cornerRadius = 5
        
        view.addSubview(googleLoginButton)
        googleLoginButton.anchor(top: facebookLoginButton.bottomAnchor, paddingTop: 24)
        googleLoginButton.centerX(inView: view)
        googleLoginButton.setDimensions(height: 50, width: 360)
        googleLoginButton.layer.cornerRadius = 5
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}

// MARK: - FormViewModel

extension LoginController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        loginButton.isEnabled = viewModel.formIsValid
    }
}

// MARK: - ResetPasswordControllerDelegate

extension LoginController: ResetPasswordControllerDelegate {
    func controllerDidSendResetPasswordLink(_ controller: ResetPasswordController) {
        navigationController?.popViewController(animated: true)
        showMessage(withTitle: "Success", message: "We sent a link to your email to reset your password")
    }
}

// MARK: - GIDSignInDelegate

extension LoginController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        showLoader(true)
        AuthService.loginWithGoogle(didSignInFor: user) { uid, shouldCreateUsername, error in
//            self.showLoader(false)
            
            if let error = error {
                self.showMessage(withTitle: "Error", message: error.localizedDescription)
                return
            }
            
            self.auth.registerUser(email: user!.profile!.email, password: "password", firstName: user!.profile!.givenName!, lastName: user!.profile?.familyName! ?? "", appleId: "") { (response, usr) in
                self.showLoader(false)
                if let u = usr {
                    let profile = ProfileService.make()
                    profile.user = u
                    if shouldCreateUsername {
                        guard let uid = uid else { return }
                        let controller = UsernameController(uid: uid)
                        controller.delegate = self.delegate
                        self.navigationController?.pushViewController(controller, animated: true)
                    } else {
                        self.delegate?.authenticationDidComplete()
                    }
                }
            }
        }
    }
}
