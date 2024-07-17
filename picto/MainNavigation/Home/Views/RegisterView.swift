import Foundation
import UIKit
import Combine
import SkyFloatingLabelTextField
import SupabaseManager

class RegisterView: UIView {

//    let auth = AuthenticationService.sharedInstance

    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical

        stack.spacing = 50

        return stack
    }()

    private lazy var btnExit: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setImage(R.image.cancel()?.resize(CGSize(width: 20, height: 20)).tint(.black), for: .normal)

        button.addTarget(self, action: #selector(exitRegistration(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var registerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textAlignment = .center
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 16)

        label.text = "Create an account"

        return label
    }()

    private lazy var errorLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textAlignment = .center
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0

        return label
    }()

    private lazy var firstNameField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "First Name"
        field.title = "First Name"
        field.textColor = .black

        return field
    }()

    private lazy var lastNameField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Last Name"
        field.title = "Last Name"
        field.textColor = .black

        return field
    }()

    private lazy var emailField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.textColor = .black

        field.placeholder = "Email"
        field.title = "Email address"
        field.errorColor = .systemRed

        field.addTarget(self, action: #selector(verifyEmail(_:)), for: .editingChanged)

        return field
    }()

    private lazy var passwordField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        field.isSecureTextEntry = true
        field.autocapitalizationType = .none

        field.placeholder = "Password"
        field.title = "Password"
        field.errorColor = .systemRed
        field.textColor = .black

        field.addTarget(self, action: #selector(verifyPassword(_:)), for: .editingChanged)

        return field
    }()

    private lazy var confirmPasswordField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        field.isSecureTextEntry = true
        field.autocapitalizationType = .none

        field.placeholder = "Confirm Password"
        field.title = "Confirm Password"
        field.errorColor = .systemRed
        field.textColor = .black


        field.addTarget(self, action: #selector(verifyConfirmPassword(_:)), for: .editingChanged)

        return field
    }()

    private lazy var btnSubmit: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("Register", for: .normal)

        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .defined.cyan100()

        button.layer.cornerRadius = 4

        button.addTarget(self, action: #selector(submitRegistration(_:)), for: .touchUpInside)

        return button
    }()

    init() {
        super.init(frame: .zero)
        self.hideKeyboard()
        setupViews()
        resetValues()
    }

//    convenience init() {
//        self.init(frame: .zero)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RegisterView {
    func setupViews() {

        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white

        addSubviews([
            btnExit,
            vStack,
            btnSubmit
        ])

        NSLayoutConstraint.activate([
            btnExit.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            btnExit.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 5),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
            btnSubmit.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 50),
            btnSubmit.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        vStack.addArrangedSubviews([
            registerLabel,
            errorLbl,
            firstNameField,
            lastNameField,
            emailField,
            passwordField,
            confirmPasswordField
        ])

        NSLayoutConstraint.activate([
            btnSubmit.widthAnchor.constraint(equalToConstant: 150)
        ])

    }
}

// MARK: - Functions
extension RegisterView {
    private func verifyInfo() -> Bool {
        if (firstNameField.text != "" && lastNameField.text != "" && emailField.errorMessage == "" && passwordField.errorMessage == "" && confirmPasswordField.errorMessage == "") {
            return true
        } else {
            return false
        }
    }

    private func resetValues() {
        errorLbl.text = ""
        firstNameField.text = ""
        lastNameField.text = ""
        emailField.text = ""
        emailField.errorMessage = ""
        passwordField.text = ""
        passwordField.errorMessage = ""
        confirmPasswordField.text = ""
        confirmPasswordField.errorMessage = ""
    }
}

// MARK: - Actions
extension RegisterView {

    @objc func submitRegistration(_ sender: UIButton) {
#warning("Handle registration")
        if verifyInfo() {
            errorLbl.text = ""
            // resetValues()
            registerUser()

            print("successfully registered")
        } else {
            errorLbl.text = "Oops! Something went wrong! Please verify your information"
            print("Fix your mistakes")
        }
    }

    @objc func exitRegistration(_ sender: UIButton) {
        resetValues()
        NotificationCenter.default.post(name: NotificationNames.dismissViewToHome, object: nil)
    }

    @objc func verifyEmail(_ textfield: UITextField) {
        if let text = textfield.text {
            if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {
                if(text.count < 3 || !text.contains("@")) {
                    floatingLabelTextField.errorMessage = "Invalid email"
                } else if !text.contains(".") {
                    floatingLabelTextField.errorMessage = "Invalid email"
                } else {
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
    }

    @objc func verifyPassword(_ textfield: UITextField) {
        if let text = textfield.text {
            if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {

                if (text.count < 5) {
                    errorLbl.text = "Password needs at least 5 characters and 1 number or special character"
                    floatingLabelTextField.errorMessage = "Invalid password"
                } else if text.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil {

                    if text.range(of: #"(?=.*\d)"#, options: .regularExpression) == nil {
                        errorLbl.text = "Password needs at least 5 characters and 1 number or special character"
                        floatingLabelTextField.errorMessage = "Invalid password"
                    } else {
                        errorLbl.text = ""
                        floatingLabelTextField.errorMessage = ""
                    }
                } else {
                    errorLbl.text = ""
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
    }

    @objc func verifyConfirmPassword(_ textfield: UITextField) {
        if let text = textfield.text {
            if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {

                if text != passwordField.text {
                    floatingLabelTextField.errorMessage = "Not matching passwords"
                } else {
                    floatingLabelTextField.errorMessage = ""
                }

            }
        }
    }
    
    private func registerUser() {

        guard let email = emailField.text?.noSpaces(), let password = passwordField.text else { return }

    let firstName = firstNameField.text?.noSpaces()
    let lastName = lastNameField.text?.noSpaces()
//        auth.registerUser(email: emailField.text!.noSpaces(), password: passwordField.text!, firstName: firstNameField.text!.noSpaces(), lastName: lastNameField.text!.noSpaces(), appleId: nil) { (response, u) in
//            Timer.schedule(delay: 0.3) { (t) in
//                switch response {
//                case .Success:
//                    guard let usr = u else { return }
//                    self.auth.authenticationSuccess(user: usr)
//                    NotificationCenter.default.post(name: NotificationNames.didRegister, object: usr)
//                case .Error:
//                    self.errorLbl.text = "Error creating acount, please try again later."
//                case .InvalidName:
//                    self.errorLbl.text = "Invalid Name"
//                case .InvalidNumber:
//                    return
//                case .InvalidPassword:
//                    self.errorLbl.text = "Invalid Password"
//                case .UnavaliableNumber:
//                    return
//                }
//
//            }
//
//        }
        let manager = SupabaseAuthenticationManager.sharedInstance

        manager.authenticate(.email, .signup, AuthObject(email: email, password: password), completion: { response, user in
            switch response {
            case .success:
                guard let id = user?.id else { return }
                print("")
                let user = BMUser(id: id, username: "", firstName: firstName ?? "", lastName: lastName ?? "", email: email, bio: "", website: "", showFullName: false, avatar: "", posts: [])
                NotificationCenter.default.post(name: NotificationNames.willShowUsernameSelection, object: user)
            case .error:
                print("")
            }
        })

        //                    self.auth.authenticationSuccess(user: usr)
        //                    NotificationCenter.default.post(name: NotificationNames.didRegister, object: usr)

    }

}
