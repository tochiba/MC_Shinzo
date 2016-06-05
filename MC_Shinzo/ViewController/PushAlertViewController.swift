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
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else {
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
        if let currentVer = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            return NSUserDefaults.standardUserDefaults().boolForKey(currentVer+"SHOW_PUSH_ALERT")
        }
        return false
    }
    
    class func setDisplayed() {
        if let currentVer = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: currentVer+"SHOW_PUSH_ALERT")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    class func checkPushAlert(viewController: UIViewController?) {
        if ifNeedPushAlert() {
            weak var vc = viewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let nVC = storyboard.instantiateViewControllerWithIdentifier("PushAlertViewController") as? PushAlertViewController {
                vc?.presentViewController(nVC, animated: true, completion: nil)
            }
        }
    }

    @IBAction func didPushOk(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {
            PushAlertViewController.setDisplayed()
            OneSignal.defaultClient().registerForPushNotifications()
        })
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sendScreenNameLog()
    }
}