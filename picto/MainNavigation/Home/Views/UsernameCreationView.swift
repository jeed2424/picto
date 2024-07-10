//
//  UsernameCreationView.swift
//  picto
//
//  Created by Jay on 2024-03-28.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField
import SupabaseManager

class UsernameCreationView: UIView {
    let auth = AuthenticationService.make()

    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical

        stack.spacing = 50

        return stack
    }()

    private lazy var registerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textAlignment = .center
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 16)

        label.text = "What is your username?"

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

    private lazy var usernameField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.textColor = .black

        field.placeholder = "Username"
        field.title = "Username"
        field.errorColor = .systemRed

        field.addTarget(self, action: #selector(verifyUsername(_:)), for: .editingChanged)

        return field
    }()

    private lazy var btnSubmit: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("Submit", for: .normal)

        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .defined.cyan100()

        button.layer.cornerRadius = 4

        button.addTarget(self, action: #selector(submitRegistration(_:)), for: .touchUpInside)

        return button
    }()

    private var firstName: String?
    private var lastName: String?
    private var email: String?
    private var userId: UUID?

    init() {
        super.init(frame: .zero)

        self.hideKeyboard()
        setupViews()
        resetValues()

        self.backgroundColor = .cyan
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValues(userId: UUID, firstName: String, lastName: String, email: String) {

        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.userId = userId
    }
}

extension UsernameCreationView {
    func setupViews() {

        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white

        addSubviews([
            vStack,
            btnSubmit
        ])

        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
            btnSubmit.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 50),
            btnSubmit.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        vStack.addArrangedSubviews([
            registerLabel,
            errorLbl,
            usernameField
        ])

        NSLayoutConstraint.activate([
            btnSubmit.widthAnchor.constraint(equalToConstant: 150)
        ])

    }
}

// MARK: - Functions
extension UsernameCreationView {
    private func verifyInfo() -> Bool {
        if usernameField.errorMessage == "" {
            return true
        } else {
            return false
        }
    }

    private func resetValues() {
        errorLbl.text = ""
        usernameField.text = ""
        usernameField.errorMessage = ""
    }
}

// MARK: - Actions
extension UsernameCreationView {

    @objc func submitRegistration(_ sender: UIButton) {
#warning("Handle registration")
        if verifyInfo() {
            errorLbl.text = ""
            // resetValues()
            saveNewUser()

            print("successfully registered")
        } else {
            errorLbl.text = "Oops! Something went wrong! Please verify your information"
            print("Fix your mistakes")
        }
    }

    @objc func verifyUsername(_ textfield: UITextField) {
        if let text = textfield.text {
            if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {
                if text.count < 3 {
                    floatingLabelTextField.errorMessage = "Username must have at least 3 characters"
                } else if text.contains(" ") {
                    floatingLabelTextField.errorMessage = "Username must not contain spaces"
                } else {
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
    }

    private func saveNewUser() {
        guard let userId = userId, let username = usernameField.text?.noSpaces(), let firstName = firstName, let lastName = lastName, let email = email else { return }

        let manager = SupabaseAuthenticationManager.sharedInstance

        let user = DbUser(id: userId, username: username, firstName: firstName, lastName: lastName, email: email)

        manager.createNewUser(user: user, completion: { id in
            if id != nil {
//                self.auth.authenticationSuccess(user: usr)
                if let user = manager.authenticatedUser {
                    let bmUser = BMUser(id: user.id, username: user.username, firstName: user.firstName, lastName: user.lastName, email: user.email)
                    let auth = AuthenticationService.make()
                    auth.authenticationSuccess(user: bmUser)
                    NotificationCenter.default.post(name: NotificationNames.didRegister, object: bmUser)
                }
            }
        })

//        manager.authenticate(.email, .signup, AuthObject(email: "", password: ""), completion: { response, user in
//            switch response {
//            case .success:
//                print("")
//            case .error:
//                print("")
//            }
//        })

//                            self.auth.authenticationSuccess(user: usr)
        //                    NotificationCenter.default.post(name: NotificationNames.didRegister, object: usr)

    }

}
