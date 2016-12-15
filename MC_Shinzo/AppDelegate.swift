//
//  AppDelegate.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/03/26.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import NCMB
import Fabric
import Crashlytics
import Meyasubaco

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mode: VideoListViewController.Mode = .Popular
    var isShortcut: Bool = false
//    func applicationDidFinishLaunching(_ application: UIApplication) {}
//    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {}
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        Fabric.with([Crashlytics.self])
        NCMB.setApplicationKey(API_ID.NCMB_APP_KEY, clientKey: API_ID.NCMB_CLIENT_KEY)
        Meyasubaco.setApiKey(API_KEY.Meyasubaco)
        TrackingManager.sharedInstance.setup()
        
        let _ = OneSignal(launchOptions: launchOptions, appId: APP_ID.OneSignal, handleNotification: nil, autoRegister: false)
        OneSignal.defaultClient().enable(inAppAlertNotification: true)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        self.mode = VideoListViewController.Mode.Favorite
        self.isShortcut = true
        completionHandler(true)
    }

}

extension UIApplication {
    static func isLandscape() -> Bool {
        return UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)
    }
    
    static func isPortrait() -> Bool {
        return UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
    }
    
    static func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    static func isSimulator() -> Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

