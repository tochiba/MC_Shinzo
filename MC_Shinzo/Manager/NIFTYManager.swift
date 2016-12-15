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
        q?.limit = 1000
        q?.order(byDescending: "createDate")
        q?.findObjectsInBackground({
            (array, error) in
            if error == nil {
                var aArray: [Video] = []
                for a in array! {
                    
                    if let _a = a as? NCMBObject {
                        if  let i = _a.object(forKey: VideoKey.idKey) as? String,
                            let ana = _a.object(forKey: VideoKey.categoryNameKey) as? String,
                            let d = _a.object(forKey: VideoKey.dateKey) as? String,
                            let t = _a.object(forKey: VideoKey.titleKey) as? String,
                            let th = _a.object(forKey: VideoKey.thumbnailUrlKey) as? String {
                            
                            let an = Video()
                            an.id = i
                            an.categoryName = ana
                            an.date = d
                            an.title = t
                            an.thumbnailUrl = th
                            if let de = _a.object(forKey: VideoKey.descriKey) as? String {
                                an.descri = de
                            }
                            if let v = _a.object(forKey: VideoKey.videoUrlKey) as? String {
                                an.videoUrl = v
                            }
                            an.likeCount = 0
                            if let l = _a.object(forKey: VideoKey.likeCountKey) as? Int {
                                an.likeCount = l
                            }
                            if let cn = _a.object(forKey: VideoKey.channelNameKey) as? String {
                                an.channelName = cn
                            }
                            if let ci = _a.object(forKey: VideoKey.channelIdKey) as? String {
                                an.channelId = ci
                            }

                            aArray.append(an)
                        }
                    }
                }
                
                let limitNum: Int32 = 1000
                if aArray.count == Int(limitNum) {
                    var skip: Int32 = 1000
                    self.loadDeliveredVideos(&skip, array: &aArray)
                    return
                }

                self.deliverVideos = aArray
                APIManager.sharedInstance.delegate?.didFinishLoad(aArray)
            }
        })
    }

    func loadDeliveredVideos( _ skip: inout Int32, array aArray: inout [Video]) {
        DispatchQueue.main.async { [skip, aArray] in
            var skip = skip
            var aArray = aArray
            let limitNum: Int32 = 1000
            let q = NCMBQuery(className: Video.className())
            q?.limit = limitNum
            q?.skip = skip
            q?.order(byDescending: "createDate")
            q?.findObjectsInBackground({
                (array, error) in
                if error == nil {
                    for a in array! {
                        if let _a = a as? NCMBObject {
                            if  let i = _a.object(forKey: VideoKey.idKey) as? String,
                                let ana = _a.object(forKey: VideoKey.categoryNameKey) as? String,
                                let d = _a.object(forKey: VideoKey.dateKey) as? String,
                                let t = _a.object(forKey: VideoKey.titleKey) as? String,
                                let th = _a.object(forKey: VideoKey.thumbnailUrlKey) as? String {
                                
                                let an = Video()
                                an.id = i
                                an.categoryName = ana
                                an.date = d
                                an.title = t
                                an.thumbnailUrl = th
                                if let de = _a.object(forKey: VideoKey.descriKey) as? String {
                                    an.descri = de
                                }
                                if let v = _a.object(forKey: VideoKey.videoUrlKey) as? String {
                                    an.videoUrl = v
                                }
                                an.likeCount = 0
                                if let l = _a.object(forKey: VideoKey.likeCountKey) as? Int {
                                    an.likeCount = l
                                }
                                if let cn = _a.object(forKey: VideoKey.channelNameKey) as? String {
                                    an.channelName = cn
                                }
                                if let ci = _a.object(forKey: VideoKey.channelIdKey) as? String {
                                    an.channelId = ci
                                }
                                
                                aArray.append(an)
                            }
                        }
                    }
                    if aArray.count == Int(skip + limitNum) {
                        skip += limitNum
                        self.loadDeliveredVideos(&skip, array: &aArray)
                        return
                    }
                    
                    self.deliverVideos = aArray
                    APIManager.sharedInstance.delegate?.didFinishLoad(aArray)
                }
            })
        }
    }

    func isDeliveredVideo(_ video: Video) -> Bool {
        if let _ = self.deliverVideos.index(where: {$0.id == video.id}) {
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
    func loadDeliveredChannels(_ aDelegate: NIFTYManagerChannelDelegate? = nil) {
        weak var del = aDelegate
        let q = NCMBQuery(className: Channel.className())
        q?.limit = 500
        q?.order(byDescending: "createDate")
        q?.findObjectsInBackground({
            (array, error) in
            if error == nil {
                var aArray: [Channel] = []
                for a in array! {
                    if let _a = a as? NCMBObject {
                        if  let cn = _a.object(forKey: VideoKey.channelNameKey) as? String,
                            let ci = _a.object(forKey: VideoKey.channelIdKey) as? String {
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
    
    func isDeliveredChannel(_ channel: Channel) -> Bool {
        if let _ = self.deliverChannels.index(where: {$0.channelId == channel.channelId}) {
            return true
        }
        return false
    }
    
    func isDeliveredChannel(_ video: Video) -> Bool {
        if let _ = self.deliverChannels.index(where: {$0.channelId == video.channelId}) {
            return true
        }
        return false
    }
    
    func deliverThisChannel(_ channel: Channel) {
        if channel.channelId.utf16.count == 0 {
            return
        }
        
        if !isDeliveredChannel(channel) {
            backgroundSaveChannel(channel)
        }
    }
    
    func deliverThisChannel(_ video: Video) {
        if video.channelId.utf16.count == 0 {
            return
        }
        let c = convert(video)
        if !isDeliveredChannel(c) {
            backgroundSaveChannel(c)
        }
    }
    
    func deleteThisChannel(_ channel: Channel, aDelegate: NIFTYManagerChannelDelegate? = nil) {
        let q = NCMBQuery(className: Channel.className())
        q?.limit = 1
        q?.whereKey(VideoKey.channelIdKey, equalTo: channel.channelId)
        q?.findObjectsInBackground({
            (array, error) in
            if error == nil {
                for a in array! {
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
    
    fileprivate func convert(_ video: Video) -> Channel {
        let c = Channel()
        c.channelName = video.channelName
        c.channelId = video.channelId
        return c
    }

    fileprivate func backgroundSaveChannel(_ channel: Channel) {
        channel.saveInBackground({ error in
            if error != nil {
                // Error
            }
            self.loadDeliveredChannels()
        })
    }
    
    fileprivate func backgroundDeleteChannel(_ channel: NCMBObject, aDelegate: NIFTYManagerChannelDelegate? = nil) {
        channel.deleteInBackground({ error in
            if error != nil {
                // Error
            }
            self.loadDeliveredChannels(aDelegate)
        })
    }
}

class NIFTYManager {
    static let sharedInstance = NIFTYManager()
    fileprivate var videoDic: [String:[Video]] = [:]
    fileprivate var delegateDic: [String: NIFTYManagerDelegate?] = [:]
    fileprivate var deliverVideos: [Video] = []
    fileprivate var deliverChannels: [Channel] = []
    
    init() {
        loadDeliveredVideos()
        loadDeliveredChannels()
    }
    
    func illegalThisVideo(_ video: Video) {
        let v = IllegalVideo()
        v.id = video.id
        v.title = video.title
        v.date = video.date
        v.categoryName = video.categoryName
        
        v.saveInBackground({ error in
            if error != nil {
                // Error
            }
        })
    }
    
    func getDeliverVideoList() -> [Video] {
        return self.deliverVideos
    }
    
    func deliverThisVideo(_ video: Video, isAuto: Bool = false) {
        if video.id.utf16.count == 0 || isDeliveredVideo(video) {
            return
        }
        
        let q = NCMBQuery(className: Video.className())
        q?.limit = 1
        q?.whereKey(VideoKey.idKey, equalTo: video.id)//配信済みかチェックするため
        q?.findObjectsInBackground({
            (array, error) in
            if error == nil {
                //配信済みかチェックするため
                if array?.count == 0 {
                    let date = NSDate()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMdd"
                    if  let i = Int(dateFormatter.string(from: date as Date)) {
                        video.dateInteger = i
                    }
                    self.backgroundSaveObject(video)
                    TwitterManager.sharedInstance.searchTweet(URL.YoutubeShare + video.id)
                    TwitterManager.sharedInstance.searchTweet(video.title)
                    TwitterManager.sharedInstance.postTweet(video)
                    if isAuto {
                        self.refreshNewCategory()
                    }
                }
            }
        })
    }
    
    func deleteThisVideo(_ video: Video) {
        let q = NCMBQuery(className: Video.className())
        q?.limit = 1
        q?.whereKey(VideoKey.idKey, equalTo: video.id)
        q?.findObjectsInBackground({
            (array, error) in
            if error == nil {
                for a in array! {
                    if let _a = a as? NCMBObject {
                        self.backgroundDeleteObject(_a)
                    }
                }
            }
        })
    }
    
    func refreshNewCategory() {
        if let bvc = UIApplication.shared.keyWindow?.rootViewController as? BaseViewController {
            bvc.setDrawerState(.closed, animated: true)
            if let mvc = bvc.mainViewController as? MainViewController {
                mvc.mode = .New
                mvc.setData()
            }
        }
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
    fileprivate func backgroundSaveObject(_ video: Video) {
        video.saveInBackground({ error in
            if error != nil {
                // Error
            }
            self.loadDeliveredVideos()
        })
    }

    fileprivate func backgroundDeleteObject(_ video: NCMBObject) {
        video.deleteInBackground({ error in
            if error != nil {
                // Error
            }
            self.loadDeliveredVideos()
        })
    }

    func getVideos(_ query: String, isEncoded: Bool=false) -> [Video] {
        
        var encodedString = ""
        if !isEncoded {
            guard let encoded = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
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

    func search(_ query: String, aDelegate: NIFTYManagerDelegate?) {
        guard let encodedString = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return
        }
        
        weak var del = aDelegate
        self.delegateDic[encodedString] = del
        
        let q = NCMBQuery(className: Video.className())
        q?.limit = 200
        // 新着順
        q?.order(byDescending: "createDate")
        q?.whereKey(VideoKey.categoryNameKey, equalTo: encodedString)
        q?.findObjectsInBackground({
            (array, error) in
            if error == nil {
                var aArray: [Video] = []
                for a in array! {
                    
                    if let _a = a as? NCMBObject {
                        if  let i = _a.object(forKey: VideoKey.idKey) as? String,
                            let ana = _a.object(forKey: VideoKey.categoryNameKey) as? String,
                            let d = _a.object(forKey: VideoKey.dateKey) as? String,
                            let t = _a.object(forKey: VideoKey.titleKey) as? String,
                            let th = _a.object(forKey: VideoKey.thumbnailUrlKey) as? String {
                            
                            let an = Video()
                            an.id = i
                            an.categoryName = ana
                            an.date = d
                            an.title = t
                            an.thumbnailUrl = th
                            if let de = _a.object(forKey: VideoKey.descriKey) as? String {
                                an.descri = de
                            }
                            if let v = _a.object(forKey: VideoKey.videoUrlKey) as? String {
                                an.videoUrl = v
                            }
                            an.likeCount = 0
                            if let l = _a.object(forKey: VideoKey.likeCountKey) as? Int {
                                an.likeCount = l
                            }
                            if let cn = _a.object(forKey: VideoKey.channelNameKey) as? String {
                                an.channelName = cn
                            }
                            if let ci = _a.object(forKey: VideoKey.channelIdKey) as? String {
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
    
    func search(_ isNew: Bool=false, aDelegate: NIFTYManagerDelegate?) {
        
        let q = NCMBQuery(className: Video.className())
        
        if isNew {
            q?.order(byDescending: "createDate")
            q?.limit = 200
        }
        else {
            // Likeの多さ順
            q?.order(byDescending: "likeCount")
            q?.limit = 30
            
            let date = Date(timeIntervalSinceNow: -60 * 60 * 24 * 14) //2週間前
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            if  let i = Int(dateFormatter.string(from: date as Date)) {
                q?.whereKey(VideoKey.dateIntegerKey, greaterThan: i)
            }
        }
        
        let str = isNew ? "New":"Popular"
        weak var del = aDelegate
        self.delegateDic[str] = del
        
        q?.findObjectsInBackground({
            (array, error) in
            if error == nil {
                var aArray: [Video] = []
                for a in array! {
                    
                    if let _a = a as? NCMBObject {
                        if  let i = _a.object(forKey: VideoKey.idKey) as? String,
                            let ana = _a.object(forKey: VideoKey.categoryNameKey) as? String,
                            let d = _a.object(forKey: VideoKey.dateKey) as? String,
                            let t = _a.object(forKey: VideoKey.titleKey) as? String,
                            let th = _a.object(forKey: VideoKey.thumbnailUrlKey) as? String {
                            
                            let an = Video()
                            an.id = i
                            an.categoryName = ana
                            an.date = d
                            an.title = t
                            an.thumbnailUrl = th
                            if let de = _a.object(forKey: VideoKey.descriKey) as? String {
                                an.descri = de
                            }
                            if let v = _a.object(forKey: VideoKey.videoUrlKey) as? String {
                                an.videoUrl = v
                            }
                            an.likeCount = 0
                            if let l = _a.object(forKey: VideoKey.likeCountKey) as? Int {
                                an.likeCount = l
                            }
                            if let cn = _a.object(forKey: VideoKey.channelNameKey) as? String {
                                an.channelName = cn
                            }
                            if let ci = _a.object(forKey: VideoKey.channelIdKey) as? String {
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
    
    func searchFromContents(_ query: String, aDelegate: NIFTYManagerDelegate?) {
        guard let encodedString = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return
        }
        
        weak var del = aDelegate
        self.delegateDic[encodedString] = del
        
        var aArray: [Video] = []
        for a in self.deliverVideos {
            if a.title.contains(query.uppercased()) || a.title.contains(query.lowercased()) || a.descri.contains(query.uppercased()) || a.descri.contains(query.lowercased()) {
                aArray.append(a)
            }
        }
        self.videoDic[encodedString] = aArray
        
        if let targetDel = self.delegateDic[encodedString] {
            targetDel?.didLoad()
        }
    }


    // Like
    func incrementLike(_ video: Video) {
        // id から LikeObject 撮ってきてインクリメントしてSave
        let q = NCMBQuery(className: Video.className())
        q?.limit = 1
        q?.whereKey(VideoKey.idKey, equalTo: video.id)
        q?.findObjectsInBackground({
            (array, error) in
            if error == nil {
                for a in array! {
                    if let _a = a as? NCMBObject {
                        if  let l = _a.object(forKey: VideoKey.likeCountKey) as? Int,
                            let id = _a.object(forKey: VideoKey.idKey) as? String {
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
    
    fileprivate func setLike(_ video: NCMBObject, count: Int) {
        video.setObject(count+1, forKey: VideoKey.likeCountKey)
        video.saveInBackground({ error in
            if error != nil {
                // Error
            }
        })
    }
}

