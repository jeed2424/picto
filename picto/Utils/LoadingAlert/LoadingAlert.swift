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

public class LoadingAlertController: UIViewController {
    
    public static var defaultActivityIndicatorColor: UIColor? = nil
    public static var defaultBackgroundStyle: UIBlurEffect.Style = .prominent
        
    public static var defaultSize = CGSize(width: 120, height: 120)
    public static var defaultCornerRadius: CGFloat = 15
    
    private let backgroundView: UIVisualEffectView
    
    private let activityIndicatorView = UIActivityIndicatorView(
        style: { if #available(iOS 13.0, *) { return .large } else { return .whiteLarge } }()
    )
    
    private let transition = AlertTransition()
    private let size: CGSize = LoadingAlertController.defaultSize
    private let cornerRadius: CGFloat = LoadingAlertController.defaultCornerRadius
    
    public init(
        activityIndicatorColor: UIColor? = nil,
        backgroundStyle: UIBlurEffect.Style? = nil
    ) {
        
        self.backgroundView = UIVisualEffectView(
            effect: UIBlurEffect(
                style: backgroundStyle ?? LoadingAlertController.defaultBackgroundStyle
            )
        )
            
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self.transition
        
        backgroundView.layer.cornerRadius = cornerRadius
        backgroundView.layer.masksToBounds = true
        
        if let color = activityIndicatorColor ?? LoadingAlertController.defaultActivityIndicatorColor {
            activityIndicatorView.color = color
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        
        NSLayoutConstraint.activate([
            
            backgroundView.widthAnchor.constraint(equalToConstant: size.width),
            backgroundView.heightAnchor.constraint(equalToConstant: size.height),
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicatorView.startAnimating()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        activityIndicatorView.stopAnimating()
    }
}
