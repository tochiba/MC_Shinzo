//
//  MainViewController.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/05/24.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit
import KYDrawerController

protocol BaseControllerDelegate: class {
    func didSelectCell(_ mode: VideoListViewController.Mode, query: String)
}

class BaseViewController: KYDrawerController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        if let dvc = self.drawerViewController as? DrawerViewController {
            dvc.delegate = self
        }
        checkShortcut()
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.didBecomeActivee(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.willEnterFore(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    func didBecomeActivee(notification: NSNotification?) {
        checkShortcut()
    }
    
    func willEnterFore(notification: NSNotification?) {
        checkShortcut()
    }

    func checkShortcut() {
        PushAlertViewController.checkPushAlert(self)
        if let adel = UIApplication.shared.delegate as? AppDelegate, adel.isShortcut {
            if let mvc = self.mainViewController as? MainViewController {
                mvc.mode = adel.mode
                mvc.setData()
                adel.isShortcut = false
            }
        }        
    }
    deinit {
        self.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
}
extension BaseViewController: KYDrawerControllerDelegate {
    func drawerController(_ drawerController: KYDrawerController, stateChanged state: KYDrawerController.DrawerState) {
        UIApplication.shared.isStatusBarHidden = state == .opened
    }
}
extension BaseViewController: BaseControllerDelegate {
    func didSelectCell(_ mode: VideoListViewController.Mode, query: String) {
        self.setDrawerState(.closed, animated: true)
        if let mvc = self.mainViewController as? MainViewController {
            mvc.mode = mode
            mvc.queryString = query
            mvc.setupLayout()
            mvc.setData()
        }
    }
}

class MainViewController: VideoListViewController {
    @IBAction func didPushOpenButton(_ sender: AnyObject) {
        if let pvc = self.parent as? BaseViewController {
            let state: KYDrawerController.DrawerState = pvc.drawerState == .opened ? KYDrawerController.DrawerState.closed : KYDrawerController.DrawerState.opened
            pvc.setDrawerState(state, animated: true)
        }
    }
    @IBAction func didPushSearchButton(_ sender: AnyObject) {
        let vc = VideoListViewController.getInstanceWithMode(mode: .Search)
        let nvc = AnimationNavigationController(rootViewController: vc)
        nvc.setBlackStyle()
        self.present(nvc, animated: true, completion: {})
    }
}

class DrawerViewController: SettingViewController {
}

class AnimationNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    func setBlackStyle() {
        self.navigationBar.barStyle = .black
    }
}
extension AnimationNavigationController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpTransitionAnimater(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpTransitionAnimater(presenting: false)
    }
}
