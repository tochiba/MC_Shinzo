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
}

extension AutoDeliverManager {
    func start() {
        NIFTYManager.sharedInstance.loadDeliveredVideos()
        NIFTYManager.sharedInstance.loadDeliveredChannels(self)
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
            NIFTYManager.sharedInstance.deliverThisVideo(v)
        }
    }
}