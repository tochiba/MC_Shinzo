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
        q.limit = 200
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
                                
                                aArray.append(an)
                        }
                    }
                }
                self.deliverVideos = aArray
                self.delegate?.didLoad()
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

class NIFTYManager {
    static let sharedInstance = NIFTYManager()
    private var VideoDic: [String:[Video]] = [:]
    private var deliverVideos: [Video] = []
    weak var delegate: NIFTYManagerDelegate?
    
    init() {
        loadDeliveredVideos()
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
            backgroundSaveObject(video)
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
    private func backgroundSaveObject(video: Video) {
        video.saveInBackgroundWithBlock({ error in
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
        
        guard let array = self.VideoDic[encodedString] else {
            return []
        }
        
        return array
    }

    func search(query: String, aDelegate: NIFTYManagerDelegate?) {
        self.delegate = aDelegate
        
        guard let encodedString = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else {
            return
        }
        
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
                                
                                aArray.append(an)
                        }
                    }
                }
                self.VideoDic[encodedString] = aArray
            }
            self.delegate?.didLoad()
        })
    }
    
    func search(isNew: Bool=false, aDelegate: NIFTYManagerDelegate?) {
        self.delegate = aDelegate
        
        let q = NCMBQuery(className: Video.className())
        q.limit = 50
        if isNew {
            q.orderByDescending("createDate")
        }
        else {
            // Likeの多さ順
            q.orderByDescending("likeCount")
        }
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
                                
                                aArray.append(an)
                        }
                    }
                }
                let str = isNew ? "New":"Popular"
                self.VideoDic[str] = aArray
            }
            self.delegate?.didLoad()
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

