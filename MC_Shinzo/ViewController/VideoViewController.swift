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

/*
enum videoQuality {
    case SuperHigh
    case High
    case Medium
    case Small
    
    var getString: XCDYouTubeVideoQuality {
        switch self {
        case .SuperHigh:
            return XCDYouTubeVideoQuality.HD1080
        case .High:
            return XCDYouTubeVideoQuality.HD720
        case .Medium:
            return XCDYouTubeVideoQuality.Medium360
        case .Small:
            return XCDYouTubeVideoQuality.Small240
        }
    }
}
*/

class VideoViewController: XCDYouTubeVideoPlayerViewController, UIViewControllerTransitioningDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        self.moviePlayer.repeatMode = .one
        self.moviePlayer.isFullscreen = true
        self.moviePlayer.prepareToPlay()
        self.moviePlayer.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sendScreenNameLog()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpTransitionAnimater(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpTransitionAnimater(presenting: false)
    }
}

class PopUpTransitionAnimater : NSObject, UIViewControllerAnimatedTransitioning {
    var presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC    = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let fromVC  = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toView  = transitionContext.view(forKey: UITransitionContextViewKey.to)
        let fromView  =  transitionContext.view(forKey: UITransitionContextViewKey.from)
        
        let popUpView = presenting ? toVC.view:fromVC.view
        let containerView = transitionContext.containerView
        toVC.view.frame     = containerView.frame
        fromVC.view.frame   = containerView.frame
        if let to = toView {
            containerView.addSubview(to)
        } else if let from = fromView {
            containerView.addSubview(from)
        }
        
        popUpView?.transform = presenting ? CGAffineTransform(scaleX: 0.01, y: 0.01) : CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        UIView.animate(withDuration: 0.4,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.7,
            options: UIViewAnimationOptions.curveEaseInOut,
            animations: { () -> Void in
                popUpView?.transform = self.presenting ?
                    CGAffineTransform(scaleX: 1.0, y: 1.0) :
                    CGAffineTransform(scaleX: 0.01, y: 0.01)
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
