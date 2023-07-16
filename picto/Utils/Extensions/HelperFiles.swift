import Foundation
import UIKit

// Screen width.
public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

public func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...4) -> T {
    let length = Int64(range.upperBound - range.lowerBound + 1)
    let value = Int64(arc4random()) % length + Int64(range.lowerBound)
    return T(value)
}

public enum FontWeight {
    case light
    case regular
    case medium
    case semiBold
    case bold
    case heavy
    case black
}

public class BaseFont: UIFont {
    
    static func get(_ weight: FontWeight, _ size: CGFloat) -> UIFont {
        switch weight {
        case .light:
            return UIFont.systemFont(ofSize: size, weight: .light)
        case .regular:
            return UIFont.systemFont(ofSize: size, weight: .regular)
//            return UIFont(name: "HelveticaNeue", size: size)!
        case .medium:
            return UIFont.systemFont(ofSize: size, weight: .medium)
//            return UIFont(name: "HelveticaNeue-Medium", size: size)!
        case .semiBold:
            return UIFont.systemFont(ofSize: size, weight: .semibold)
        case .bold:
            return UIFont.systemFont(ofSize: size, weight: .bold)
        case .heavy:
            return UIFont.systemFont(ofSize: size, weight: .heavy)
        case .black:
            return UIFont.systemFont(ofSize: size, weight: .black)
//            return UIFont(name: "HelveticaNeue-Bold", size: size)!
        }
    }
    
}

extension UIFont {
    open class func customFont(forTextStyle style: UIFont.TextStyle) -> UIFont {
        return UIFont.preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "HelveticaNeue"))

    }
}

public enum HapticType {
    case success
    case warning
    case error
    case soft
    case light
    case medium
    case heavy
}

public func addHaptic(style: HapticType) {
    switch style {
    case .soft:
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    case .light:
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    case .medium:
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    case .heavy:
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    case .success:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    case .warning:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    case .error:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    default: break
    }
}


extension Date {
    
    func dayDiff(toDate: Date) -> Int {
        let diffInDays = Calendar.current.dateComponents([.day], from: self, to: toDate).day
        return diffInDays!
    }
    
    func hourDiff(toDate: Date) -> Int {
        let diffInHours = Calendar.current.dateComponents([.hour], from: self, to: toDate).hour
        return diffInHours!
    }
    
    func minDiff(toDate: Date) -> Int {
        let diffInMins = Calendar.current.dateComponents([.minute], from: self, to: toDate).minute
        return diffInMins!
    }
    
}

class RandomNumber {
    
    static func randomLargeNum() -> Int {
        let min: UInt32 = 3333
        let max: UInt32 = 99999
        let i = min + arc4random_uniform(max - min + 1)
        let num = Int(i)
        return num
    }
    
}
