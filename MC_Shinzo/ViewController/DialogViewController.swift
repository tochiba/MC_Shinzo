//
//  DialogViewController.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/04/12.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit

class DialogViewController: UIViewController, UIViewControllerTransitioningDelegate {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sendScreenNameLog()
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