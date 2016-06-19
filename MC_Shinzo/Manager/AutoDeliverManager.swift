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
    private var channels: [Channel] = []
    var timer: NSTimer = NSTimer()
}

extension AutoDeliverManager {
    @objc func start() {
        if UIApplication.isSimulator() {
            // Simulatorは20分に一回チェック
            self.timer = NSTimer.scheduledTimerWithTimeInterval(60 * 20, target: self, selector: #selector(self.start), userInfo: nil, repeats: false)
        }
        
        NIFTYManager.sharedInstance.loadDeliveredChannels(self)
        for v in NIFTYManager.sharedInstance.getDeliverVideoList() {
            APIManager.sharedInstance.videoCheckSearch(v)
        }
        
    }
}
extension AutoDeliverManager: NIFTYManagerChannelDelegate {
    func didLoadChannel() {
        self.loadData()
    }
}
extension AutoDeliverManager {
    private func loadData() {
        self.channels = NIFTYManager.sharedInstance.getChannels()
        loadVideos()
    }
    
    private func loadVideos() {
        for c in self.channels {
            APIManager.sharedInstance.search(c.channelId, aDelegate: self, mode: .Channel)
        }
        NIFTYManager.sharedInstance.refreshNewCategory()
    }
}
extension AutoDeliverManager: SearchAPIManagerDelegate {
    func didFinishLoad(videos: [Video]) {
        for v in videos {
            v.categoryName = VideoCategory.category[0]
            NIFTYManager.sharedInstance.deliverThisVideo(v, isAuto: true)
        }
    }
}