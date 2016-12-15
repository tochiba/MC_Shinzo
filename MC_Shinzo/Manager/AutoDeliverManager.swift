//
//  AutoDeliverManager.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/05/15.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation

class AutoDeliverManager {
    static let sharedInstance = AutoDeliverManager()
    fileprivate var channels: [Channel] = []
    var timer: Timer = Timer()
}

extension AutoDeliverManager {
    @objc func start() {
        if UIApplication.isSimulator() {
            // Simulatorは20分に一回チェック
            self.timer = Timer.scheduledTimer(timeInterval: 60 * 20, target: self, selector: #selector(self.restart), userInfo: nil, repeats: false)
        }
        
        NIFTYManager.sharedInstance.loadDeliveredChannels(self)
        for v in NIFTYManager.sharedInstance.getDeliverVideoList() {
            APIManager.sharedInstance.videoCheckSearch(v)
        }
    }
    
    @objc func restart() {
        //print("Check: \(NSDate())")
        //TwitterManager.sharedInstance.startAutoFavorite()
        start()
    }
}
extension AutoDeliverManager: NIFTYManagerChannelDelegate {
    func didLoadChannel() {
        self.loadData()
    }
}
extension AutoDeliverManager {
    fileprivate func loadData() {
        self.channels = NIFTYManager.sharedInstance.getChannels()
        loadVideos()
    }
    
    fileprivate func loadVideos() {
        for c in self.channels {
            APIManager.sharedInstance.search(c.channelId, aDelegate: self, mode: .channel)
        }
        NIFTYManager.sharedInstance.refreshNewCategory()
    }
}
extension AutoDeliverManager: SearchAPIManagerDelegate {
    func didFinishLoad(_ videos: [Video]) {
        for v in videos {
            v.categoryName = VideoCategory.category[0]
            NIFTYManager.sharedInstance.deliverThisVideo(v, isAuto: true)
        }
    }
}
