//
//  VideoViewController.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/04/10.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit
import XCDYouTubeKit

class VideoViewController: XCDYouTubeVideoPlayerViewController, UIViewControllerTransitioningDelegate {
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpTransitionAnimater(presenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpTransitionAnimater(presenting: false)
    }
}

class PopUpTransitionAnimater : NSObject, UIViewControllerAnimatedTransitioning {
    var presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC    = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromVC  = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toView  = transitionContext.viewForKey(UITransitionContextToViewKey)
        let fromView  =  transitionContext.viewForKey(UITransitionContextFromViewKey)
        
        let popUpView = presenting ? toVC.view:fromVC.view
        if let containerView = transitionContext.containerView() {
            toVC.view.frame     = containerView.frame
            fromVC.view.frame   = containerView.frame
            if let to = toView {
                containerView.addSubview(to)
            } else if let from = fromView {
                containerView.addSubview(from)
            }
        }
        
        popUpView.transform = presenting ? CGAffineTransformMakeScale(0.01, 0.01) : CGAffineTransformMakeScale(1.0, 1.0)
        
        UIView.animateWithDuration(0.4,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.7,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                popUpView.transform = self.presenting ?
                    CGAffineTransformMakeScale(1.0, 1.0) :
                    CGAffineTransformMakeScale(0.01, 0.01)
                if self.presenting {
                    toView?.alpha = 1.0
                } else {
                    fromView?.alpha = 0.0
                }
            }) { (finished: Bool) -> Void in
                transitionContext.completeTransition(finished)
        }
    }
    
}