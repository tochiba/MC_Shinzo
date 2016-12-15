//
//  TrackingManager.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/05/10.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation

class TrackingManager {
    static let sharedInstance = TrackingManager()
    fileprivate var tracker: GAITracker?
    
    init() {
        setup()
    }
    
    func setup() {
        GAI.sharedInstance().trackUncaughtExceptions = true;
        GAI.sharedInstance().dispatchInterval = 20
        GAI.sharedInstance().logger.logLevel = .verbose
        self.tracker = GAI.sharedInstance().tracker(withTrackingId: API_KEY.GoogleAnalytics)
    }

    enum ActionEvent {
        case play
        case favorite
        case share
        case refresh
        
        var eventString: String {
            switch self {
            case .play:
                return "Play"
            case .favorite:
                return "Favorite"
            case .share:
                return "Share"
            case .refresh:
                return "Refresh"
            }
        }
    }
    
    func sendEventAction(_ event: ActionEvent) {
        let build = GAIDictionaryBuilder.createEvent(withCategory: "Action", action: event.eventString, label: "ct", value: 1).build()
        self.tracker?.send(build! as NSDictionary as! [String : AnyObject])
    }

    func sendEventCategory(_ category: String) {
        let build = GAIDictionaryBuilder.createEvent(withCategory: "Category", action: category, label: "pv", value: 1).build()
        self.tracker?.send(build! as NSDictionary as! [String : AnyObject])
    }
    
    func sendLogScreenName(_ name: String) {
        let build = GAIDictionaryBuilder.createScreenView().set(name, forKey: kGAIScreenName).build()
        TrackingManager.sharedInstance.tracker?.send(build! as NSDictionary as! [String : AnyObject])
    }
}

public extension UIViewController {
    func sendScreenNameLog() {
        let screenName = String(describing: type(of: self))
        TrackingManager.sharedInstance.sendLogScreenName(screenName)
    }
}
