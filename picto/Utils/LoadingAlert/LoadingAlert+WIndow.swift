//
//  LoadingAlert
//
//  Copyright (c) 2020 - Present Brandon Erbschloe - https://github.com/berbschloe
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

public struct LoadingAlert {
    
    public static var windowLevel: UIWindow.Level = .alert - 1
    
    private static var window: UIWindow?
    
    private init() {}
    
    static public func show(animated: Bool, completion: (() -> Void)?) {
        guard LoadingAlert.window == nil else {
            completion?()
            return
        }
       
        let window: UIWindow
        if #available(iOS 13.0, *) {
            window = UIApplication.shared.currentScene.map { UIWindow(windowScene: $0) } ?? UIWindow(frame: UIScreen.main.bounds)
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
       
        window.rootViewController = UIViewController()
        window.windowLevel = LoadingAlert.windowLevel
        window.isHidden = false
       
        window.rootViewController?.present(
            LoadingAlertController(),
            animated: animated,
            completion: completion
        )
       
        LoadingAlert.window = window
    }
    
    static public func hide(animated: Bool, completion: (() -> Void)?) {
        guard let window = LoadingAlert.window else {
            completion?()
            return
        }
        
        window.rootViewController?.dismiss(animated: animated) {
            LoadingAlert.window = nil
            window.isHidden = true
            completion?()
        }
    }
    
    static public func bind(to completion: (() -> Void)? = nil) -> (() -> Void) {
        show(animated: true, completion: nil)
        return {
            hide(animated: true, completion: nil)
            completion?()
        }
    }
    
    static public func bind<T>(to completion: ((T) -> Void)? = nil) -> ((T) -> Void) {
        show(animated: true, completion: nil)
        return {
            hide(animated: true, completion: nil)
            completion?($0)
        }
    }
}

extension UIApplication {
    
    @available(iOS 13.0, *)
    var currentScene: UIWindowScene? {
        return connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first
    }
}
