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
//
//  Source attribution https://github.com/sberrevoets/SDCAlertView
//  Copyright (c) 2013 Scott Berrevoets (MIT)

import UIKit

internal class AlertAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let isPresentation: Bool
    
    init(presentation: Bool) {
        isPresentation = presentation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated == true ? 0.404 : 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromController = transitionContext.viewController(forKey: .from),
            let toController = transitionContext.viewController(forKey: .to),
            let fromView = fromController.view,
            let toView = toController.view
        else {
            return
        }
        
        if isPresentation {
            transitionContext.containerView.addSubview(toView)
        }
        
        let animatingController = isPresentation ? toController : fromController
        let animatingView = animatingController.view
        animatingView?.frame = transitionContext.finalFrame(for: animatingController)
        
        if isPresentation {
            
            animatingView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            animatingView?.alpha = 0
            
            animate({
                animatingView?.transform = .identity
                animatingView?.alpha = 1
            }, inContext: transitionContext, withCompletion: { finished in
                transitionContext.completeTransition(finished)
            })
        } else {
            animate({
                animatingView?.alpha = 0
            }, inContext: transitionContext, withCompletion: { finished in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            })
        }
    }
    
    private func animate(
        _ animations: @escaping (() -> Void),
        inContext context: UIViewControllerContextTransitioning,
        withCompletion completion: @escaping (Bool) -> Void
    ) {
        
        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: 0,
            usingSpringWithDamping: 45.71,
            initialSpringVelocity: 0,
            options: [],
            animations: animations,
            completion: completion
        )
    }
}
