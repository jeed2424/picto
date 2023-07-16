import Foundation
import Alamofire
import SDWebImage
import Firebase
import FirebaseFirestore
import FirebaseAuth
import CoreMedia

enum RegisterResponseCode {
    case Success
    case Error
    case InvalidName
    case InvalidNumber
    case InvalidPassword
    case UnavaliableNumber
}

enum LoginResponseCode {
    case Success
    case Error
    case InvalidCredentials
}

class AuthenticationService: BaseService {

    let db = Firestore.firestore()
    
    override init(api: ClientAPI) {
        super.init(api: api)
    }
    
    static func make() -> AuthenticationService {
        let auth = ClientAPI.sharedInstance.authenticationService
        return auth
    }
    
    func authenticationSuccess(user: BMUser) {
        APIService.setUser(user: user)
        ProfileService.make().getCategories(user: user) { (response, cats) in
            ProfileService.make().categories = cats
        }
    }

    func createUser(email: String, password: String, firstName: String, lastName: String, completion: @escaping (RegisterResponseCode, User?) -> Swift.Void) {
//    // [START create_user]
//            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//              // [START_EXCLUDE]
//             // strongSelf.hideSpinner {
//                guard let user = authResult?.user, error == nil else {
//                //  strongSelf.showMessagePrompt(error!.localizedDescription)
//                  return
//                }
//                self.db.collection("users").document(user.uid).setData([
//                    "email": email,
//                    "firstName": firstName,
//                    "lastName": lastName
//                ]) { err in
//                    if let err = err {
//                        print("Error adding document: \(err)")
//                    } else {
//                        print("Document added with ID: \(user.uid)")
//                    }
//                }
//                self.authenticationSuccess(user: user)
//                print("\(user.email!) created")
//                completion(RegisterResponseCode.Success, user)
//               // strongSelf.navigationController?.popViewController(animated: true)
//           //   }
//              // [END_EXCLUDE]
//            }
//            // [END create_user]
}
    func registerUser(email: String, password: String, firstName: String, lastName: String, appleId: String?, completion: @escaping (RegisterResponseCode, BMUser?) -> Swift.Void) {
        log.verbose("Registering")
        let params: Parameters = ["firstName": firstName, "lastName": lastName, "email": email, "password": password, "apple_id": appleId ?? nil]
        APIService.requestAPIJson(url:"https://us-central1-picto-ce462.cloudfunctions.net/register", method: .post, parameters: params, success: { userDict in
            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
            self.authenticationSuccess(user: user)
            completion(RegisterResponseCode.Success, user)

        }, failure: { errorString in
            if (errorString == "invalid_name") {
                completion(RegisterResponseCode.InvalidName, nil)
            } else if (errorString == "invalid_number") {
                completion(RegisterResponseCode.InvalidNumber, nil)
            } else if (errorString == "invalid_password") {
                completion(RegisterResponseCode.InvalidPassword, nil)
            } else if (errorString == "unavaliable_number") {
                completion(RegisterResponseCode.UnavaliableNumber, nil)
            } else {
                log.error(errorString)
                completion(RegisterResponseCode.Error, nil)
            }
        })
    }
    
    func loginUserWithEmail(email: String, password: String, completion: @escaping (LoginResponseCode, BMUser?) -> Swift.Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
          // ...
            guard error == nil else {
                completion(LoginResponseCode.InvalidCredentials, nil)
                return
            }

            let parameters: Parameters = ["email": email]
            strongSelf.APIService.requestAPIJson(url:"https://us-central1-picto-ce462.cloudfunctions.net/login", method: .post, parameters: parameters, success: { userDict in
                let user: BMUser = UserSerializer.unserialize(JSON: userDict)
                strongSelf.authenticationSuccess(user: user)
                completion(LoginResponseCode.Success, user)
            }, failure: { errorString in
                if (errorString == "invalid_credentials") {
                    completion(LoginResponseCode.InvalidCredentials, nil)
                } else {
                    log.error("Unknown Error: " + errorString)
                    completion(LoginResponseCode.Error, nil)
                }
            })

        }

    }
//    
//    func loginUserApple(appleId: String, completion: @escaping (LoginResponseCode, BMUser?) -> Swift.Void) {
//        
//        let parameters: Parameters = ["apple_id": appleId]
//        print("trying to log in")
//        APIService.requestAPIJson(url:"https://api.warbly.net/login/apple", method: .post, parameters: parameters, success: { userDict in
//            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
//            self.authenticationSuccess(user: user)
//            completion(LoginResponseCode.Success, user)
//        }, failure: { errorString in
//            if (errorString == "invalid_credentials") {
//                completion(LoginResponseCode.InvalidCredentials, nil)
//            } else {
//                log.error("Unknown Error: " + errorString)
//                completion(LoginResponseCode.Error, nil)
//            }
//        })
//    }
//    
//    func testLogin(completion: @escaping (LoginResponseCode, BMUser?) -> Swift.Void) {
//        APIService.requestAPIJson(url: "https://api.warbly.net/login", method: .get, parameters: nil, success: { userDict in
//            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
//            self.authenticationSuccess(user: user)
//            completion(LoginResponseCode.Success, user)
//        }, failure: { errorString in
//            if (errorString == "invalid_credentials") {
//                completion(LoginResponseCode.InvalidCredentials, nil)
//                print("You are not logged in")
//            } else {
//                log.error(errorString)
//                completion(LoginResponseCode.Error, nil)
//                print("You are not logged in")
//            }
//        })
//    }

    func logout(completion: @escaping () -> Swift.Void) {
        APIService.requestAPIJson(url:"https://api.warbly.net/log_out", method: .get, parameters: nil, success: { _ in
            print("logged user out")
            completion()
        }, failure: { _ in
            completion()
        })
    }

    func getEmail(user: User) {
        let docRef = db.collection("users").document(user.uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"

                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
}
