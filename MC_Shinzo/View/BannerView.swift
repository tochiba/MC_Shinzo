//
//  BannerView.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/04/12.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class BannerView: GADBannerView, GADBannerViewDelegate {
    func setup(viewController: UIViewController, unitID: String, isDebug: Bool=false) {
        self.delegate = self
        self.adUnitID = unitID
        self.rootViewController = viewController
        self.adSize = kGADAdSizeSmartBannerPortrait
        let request = GADRequest()
        if isDebug {
            request.testDevices = [""]
        }
        self.loadRequest(request)
    }
}

class Interstitial: NSObject, GADInterstitialDelegate {
    static let sharedInstance = Interstitial()
    var interstitial: GADInterstitial!
    
    override init() {
        super.init()
        self.interstitial = createAndLoadInterstitial()
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let i = GADInterstitial(adUnitID: AD.InterstitialID)
        i.delegate = self
        let request = GADRequest()
        i.loadRequest(request)
        return i
    }
    
    func show(viewController: UIViewController) {
        if self.interstitial.isReady {
            weak var vc = viewController
            self.interstitial.presentFromRootViewController(vc)
        }        
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        self.interstitial = createAndLoadInterstitial()
    }
}