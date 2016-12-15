//
//  PushAlertViewController.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/05/29.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation

class PushAlertViewController: DialogViewController {
    class func isEnabled() -> Bool {
        guard let settings = UIApplication.shared.currentUserNotificationSettings else {
            return false
        }        
        return settings.types == UIUserNotificationType(rawValue: 7)
    }
    
    class func ifNeedPushAlert() -> Bool {
        if isEnabled() {
            return false
        }
        
        return !isDisplayed()
    }
    
    class func isDisplayed() -> Bool {
        if let currentVer = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return UserDefaults.standard.bool(forKey: currentVer+"SHOW_PUSH_ALERT")
        }
        return false
    }
    
    class func setDisplayed() {
        if let currentVer = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            UserDefaults.standard.set(true, forKey: currentVer+"SHOW_PUSH_ALERT")
            UserDefaults.standard.synchronize()
        }
    }

    class func checkPushAlert(_ viewController: UIViewController?) {
        if ifNeedPushAlert() {
            weak var vc = viewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let nVC = storyboard.instantiateViewController(withIdentifier: "PushAlertViewController") as? PushAlertViewController {
                vc?.present(nVC, animated: true, completion: nil)
            }
        }
    }

    @IBAction func didPushOk(_ sender: AnyObject) {
        dismiss(animated: true, completion: {
            PushAlertViewController.setDisplayed()
            OneSignal.defaultClient().registerForPushNotifications()
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sendScreenNameLog()
    }
}
