//
//  NIFTYManager.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/04/03.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB

protocol NIFTYManagerDelegate: class {
    func didLoad()
}

// 外部クラスからの配信済みかチェック用
extension NIFTYManager {
    func loadDeliveredVideos() {
        let q = NCMBQuery(className: Video.className())
        q.limit = 100000
        q.orderByDescending("createDate")
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            if error == nil {
                var aArray: [Video] = []
                for a in array {
                    
                    if let _a = a as? NCMBObject {
                        if  let i = _a.objectForKey(VideoKey.idKey) as? String,
                            let ana = _a.objectForKey(VideoKey.categoryNameKey) as? String,
                            let d = _a.objectForKey(VideoKey.dateKey) as? String,
                            let t = _a.objectForKey(VideoKey.titleKey) as? String,
                            let th = _a.objectForKey(VideoKey.thumbnailUrlKey) as? String {
                            
                            let an = Video()
                            an.id = i
                            an.categoryName = ana
                            an.date = d
                            an.title = t
                            an.thumbnailUrl = th
                            if let de = _a.objectForKey(VideoKey.descriKey) as? String {
                                an.descri = de
                            }
                            if let v = _a.objectForKey(VideoKey.videoUrlKey) as? String {
                                an.videoUrl = v
                            }
                            an.likeCount = 0
                            if let l = _a.objectForKey(VideoKey.likeCountKey) as? Int {
                                an.likeCount = l
                            }
                            if let cn = _a.objectForKey(VideoKey.channelNameKey) as? String {
                                an.channelName = cn
                            }
                            if let ci = _a.objectForKey(VideoKey.channelIdKey) as? String {
                                an.channelId = ci
                            }

                            aArray.append(an)
                        }
                    }
                }
                self.deliverVideos = aArray
                APIManager.sharedInstance.delegate?.didFinishLoad(aArray)
            }
        })
    }

    func isDeliveredVideo(video: Video) -> Bool {
        if let _ = self.deliverVideos.indexOf({$0.id == video.id}) {
            return true
        }
        return false
    }
}

protocol NIFTYManagerChannelDelegate: class {
    func didLoadChannel()
}
// 外部クラスからの配信済みかチェック用
extension NIFTYManager {
    // チャンネル用
    func loadDeliveredChannels(aDelegate: NIFTYManagerChannelDelegate? = nil) {
        weak var del = aDelegate
        let q = NCMBQuery(className: Channel.className())
        q.limit = 200
        q.orderByDescending("createDate")
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            if error == nil {
                var aArray: [Channel] = []
                for a in array {
                    if let _a = a as? NCMBObject {
                        if  let cn = _a.objectForKey(VideoKey.channelNameKey) as? String,
                            let ci = _a.objectForKey(VideoKey.channelIdKey) as? String {
                            let cl = Channel()
                            cl.channelName = cn
                            cl.channelId = ci
                            aArray.append(cl)
                        }
                    }
                }
                self.deliverChannels = aArray
                del?.didLoadChannel()
            }
        })
    }
    
    func isDeliveredChannel(channel: Channel) -> Bool {
        if let _ = self.deliverChannels.indexOf({$0.channelId == channel.channelId}) {
            return true
        }
        return false
    }
    
    func isDeliveredChannel(video: Video) -> Bool {
        if let _ = self.deliverChannels.indexOf({$0.channelId == video.channelId}) {
            return true
        }
        return false
    }
    
    func deliverThisChannel(channel: Channel) {
        if channel.channelId.utf16.count == 0 {
            return
        }
        
        if !isDeliveredChannel(channel) {
            backgroundSaveChannel(channel)
        }
    }
    
    func deliverThisChannel(video: Video) {
        if video.channelId.utf16.count == 0 {
            return
        }
        let c = convert(video)
        if !isDeliveredChannel(c) {
            backgroundSaveChannel(c)
        }
    }
    
    func deleteThisChannel(channel: Channel, aDelegate: NIFTYManagerChannelDelegate? = nil) {
        let q = NCMBQuery(className: Channel.className())
        q.limit = 1
        q.whereKey(VideoKey.channelIdKey, equalTo: channel.channelId)
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            if error == nil {
                for a in array {
                    if let _a = a as? NCMBObject {
                        self.backgroundDeleteChannel(_a, aDelegate: aDelegate)
                    }
                }
            }
        })
    }

    func getChannels() -> [Channel] {
        return self.deliverChannels
    }
    
    private func convert(video: Video) -> Channel {
        let c = Channel()
        c.channelName = video.channelName
        c.channelId = video.channelId
        return c
    }

    private func backgroundSaveChannel(channel: Channel) {
        channel.saveInBackgroundWithBlock({ error in
            if error != nil {
                // Error
            }
            self.loadDeliveredChannels()
        })
    }
    
    private func backgroundDeleteChannel(channel: NCMBObject, aDelegate: NIFTYManagerChannelDelegate? = nil) {
        channel.deleteInBackgroundWithBlock({ error in
            if error != nil {
                // Error
            }
            self.loadDeliveredChannels(aDelegate)
        })
    }
}

class NIFTYManager {
    static let sharedInstance = NIFTYManager()
    private var videoDic: [String:[Video]] = [:]
    private var delegateDic: [String: NIFTYManagerDelegate?] = [:]
    private var deliverVideos: [Video] = []
    private var deliverChannels: [Channel] = []
    
    init() {
        loadDeliveredVideos()
        loadDeliveredChannels()
    }
    
    func illegalThisVideo(video: Video) {
        let v = IllegalVideo()
        v.id = video.id
        v.title = video.title
        v.date = video.date
        v.categoryName = video.categoryName
        
        v.saveInBackgroundWithBlock({ error in
            if error != nil {
                // Error
            }
        })
    }
    
    func deliverThisVideo(video: Video) {
        if video.id.utf16.count == 0 {
            return
        }

        if !isDeliveredVideo(video) {
            let date = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            if  let i = Int(dateFormatter.stringFromDate(date)) {
                video.dateInteger = i
            }            
            backgroundSaveObject(video)
        }
    }
    
    func deleteThisVideo(video: Video) {
        let q = NCMBQuery(className: Video.className())
        q.limit = 1
        q.whereKey(VideoKey.idKey, equalTo: video.id)
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            if error == nil {
                for a in array {
                    if let _a = a as? NCMBObject {
                        self.backgroundDeleteObject(_a)
                    }
                }
            }
        })
    }
    /*
    private func isDelivered(video: Video) -> Bool {
        let items = getVideos(video.categoryName, isEncoded: true)
        if let _ = items.indexOf({$0.id == video.id}) {
            return true
        }
        
        return false
    }
    */
    private func backgroundSaveObject(video: Video) {
        video.saveInBackgroundWithBlock({ error in
            if error != nil {
                // Error
            }
            self.loadDeliveredVideos()
        })
    }

    private func backgroundDeleteObject(video: NCMBObject) {
        video.deleteInBackgroundWithBlock({ error in
            if error != nil {
                // Error
            }
            self.loadDeliveredVideos()
        })
    }

    func getVideos(query: String, isEncoded: Bool=false) -> [Video] {
        
        var encodedString = ""
        if !isEncoded {
            guard let encoded = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else {
                return []
            }
            encodedString = encoded
        }
        else {
            encodedString = query
        }
        
        guard let array = self.videoDic[encodedString] else {
            return []
        }
        
        return array
    }

    func search(query: String, aDelegate: NIFTYManagerDelegate?) {
        guard let encodedString = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else {
            return
        }
        
        weak var del = aDelegate
        self.delegateDic[encodedString] = del
        
        let q = NCMBQuery(className: Video.className())
        q.limit = 200
        // 新着順
        q.orderByDescending("createDate")
        q.whereKey(VideoKey.categoryNameKey, equalTo: encodedString)
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            if error == nil {
                var aArray: [Video] = []
                for a in array {
                    
                    if let _a = a as? NCMBObject {
                        if  let i = _a.objectForKey(VideoKey.idKey) as? String,
                            let ana = _a.objectForKey(VideoKey.categoryNameKey) as? String,
                            let d = _a.objectForKey(VideoKey.dateKey) as? String,
                            let t = _a.objectForKey(VideoKey.titleKey) as? String,
                            let th = _a.objectForKey(VideoKey.thumbnailUrlKey) as? String {
                            
                            let an = Video()
                            an.id = i
                            an.categoryName = ana
                            an.date = d
                            an.title = t
                            an.thumbnailUrl = th
                            if let de = _a.objectForKey(VideoKey.descriKey) as? String {
                                an.descri = de
                            }
                            if let v = _a.objectForKey(VideoKey.videoUrlKey) as? String {
                                an.videoUrl = v
                            }
                            an.likeCount = 0
                            if let l = _a.objectForKey(VideoKey.likeCountKey) as? Int {
                                an.likeCount = l
                            }
                            if let cn = _a.objectForKey(VideoKey.channelNameKey) as? String {
                                an.channelName = cn
                            }
                            if let ci = _a.objectForKey(VideoKey.channelIdKey) as? String {
                                an.channelId = ci
                            }
                            aArray.append(an)
                        }
                    }
                }
                self.videoDic[encodedString] = aArray
            }
            if let targetDel = self.delegateDic[encodedString] {
                targetDel?.didLoad()
            }
        })
    }
    
    func search(isNew: Bool=false, aDelegate: NIFTYManagerDelegate?) {
        
        let q = NCMBQuery(className: Video.className())
        
        if isNew {
            q.orderByDescending("createDate")
            q.limit = 100
        }
        else {
            // Likeの多さ順
            q.orderByDescending("likeCount")
            q.limit = 30
            
            let date = NSDate(timeIntervalSinceNow: -60 * 60 * 24 * 21) //3週間前
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            if  let i = Int(dateFormatter.stringFromDate(date)) {
                q.whereKey(VideoKey.dateIntegerKey, greaterThan: i)
            }
        }
        
        let str = isNew ? "New":"Popular"
        weak var del = aDelegate
        self.delegateDic[str] = del
        
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            if error == nil {
                var aArray: [Video] = []
                for a in array {
                    
                    if let _a = a as? NCMBObject {
                        if  let i = _a.objectForKey(VideoKey.idKey) as? String,
                            let ana = _a.objectForKey(VideoKey.categoryNameKey) as? String,
                            let d = _a.objectForKey(VideoKey.dateKey) as? String,
                            let t = _a.objectForKey(VideoKey.titleKey) as? String,
                            let th = _a.objectForKey(VideoKey.thumbnailUrlKey) as? String {
                            
                            let an = Video()
                            an.id = i
                            an.categoryName = ana
                            an.date = d
                            an.title = t
                            an.thumbnailUrl = th
                            if let de = _a.objectForKey(VideoKey.descriKey) as? String {
                                an.descri = de
                            }
                            if let v = _a.objectForKey(VideoKey.videoUrlKey) as? String {
                                an.videoUrl = v
                            }
                            an.likeCount = 0
                            if let l = _a.objectForKey(VideoKey.likeCountKey) as? Int {
                                an.likeCount = l
                            }
                            if let cn = _a.objectForKey(VideoKey.channelNameKey) as? String {
                                an.channelName = cn
                            }
                            if let ci = _a.objectForKey(VideoKey.channelIdKey) as? String {
                                an.channelId = ci
                            }
                            
                            aArray.append(an)
                        }
                    }
                }
                self.videoDic[str] = aArray
            }
            if let targetDel = self.delegateDic[str] {
                targetDel?.didLoad()
            }
        })
    }

    // Like
    func incrementLike(video: Video) {
        // id から LikeObject 撮ってきてインクリメントしてSave
        let q = NCMBQuery(className: Video.className())
        q.limit = 1
        q.whereKey(VideoKey.idKey, equalTo: video.id)
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            if error == nil {
                for a in array {
                    if let _a = a as? NCMBObject {
                        if  let l = _a.objectForKey(VideoKey.likeCountKey) as? Int,
                            let id = _a.objectForKey(VideoKey.idKey) as? String {
                            if id.utf16.count == 0 {
                                return
                            }
                            self.setLike(_a, count: l)
                        }
                    }
                }
            }
        })
    }
    
    private func setLike(video: NCMBObject, count: Int) {
        video.setObject(count+1, forKey: VideoKey.likeCountKey)
        video.saveInBackgroundWithBlock({ error in
            if error != nil {
                // Error
            }
        })
    }
}

