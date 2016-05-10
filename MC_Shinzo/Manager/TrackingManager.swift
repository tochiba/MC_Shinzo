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
    private var tracker: GAITracker?
    
    init() {
        setup()
    }
    
    func setup() {
        GAI.sharedInstance().trackUncaughtExceptions = true;
        GAI.sharedInstance().dispatchInterval = 20
        GAI.sharedInstance().logger.logLevel = .Verbose
        self.tracker = GAI.sharedInstance().trackerWithTrackingId(API_KEY.GoogleAnalytics)
    }

    enum ActionEvent {
        case Play
        case Favorite
        case Share
        case Refresh
        
        var eventString: String {
            switch self {
            case .Play:
                return "Play"
            case .Favorite:
                return "Favorite"
            case .Share:
                return "Share"
            case .Refresh:
                return "Refresh"
            }
        }
    }
    
    func sendEventAction(event: ActionEvent) {
        let build = GAIDictionaryBuilder.createEventWithCategory("Action", action: event.eventString, label: "ct", value: 1).build()
        self.tracker?.send(build as [NSObject : AnyObject])
    }

    func sendEventCategory(category: String) {
        let build = GAIDictionaryBuilder.createEventWithCategory("Category", action: category, label: "pv", value: 1).build()
        self.tracker?.send(build as [NSObject : AnyObject])
    }
    
    func sendLogScreenName(name: String) {
        let build = GAIDictionaryBuilder.createScreenView().set(name, forKey: kGAIScreenName).build()
        TrackingManager.sharedInstance.tracker?.send(build as [NSObject : AnyObject])
    }
}

public extension UIViewController {
    func sendScreenNameLog() {
        let screenName = String(self.dynamicType)
        TrackingManager.sharedInstance.sendLogScreenName(screenName)
    }
}