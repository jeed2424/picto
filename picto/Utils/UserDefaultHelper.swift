import Foundation
import UIKit
import Foil
class UserDefaultHelper: NSObject {
    @WrappedDefaultOptional(key: "userID")
    var savedUserID: UInt?

}
