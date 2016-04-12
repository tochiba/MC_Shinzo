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

class NIFTYManager {
    static let sharedInstance = NIFTYManager()
    private var animalVideoDic: [String:[AnimalVideo]] = [:]
    weak var delegate: NIFTYManagerDelegate?
    
    func illegalThisVideo(video: AnimalVideo) {
        let v = IllegalVideo()
        v.id = video.id
        v.title = video.title
        v.date = video.date
        v.animalName = video.animalName
        
        v.saveInBackgroundWithBlock({ error in
            if error != nil {
                // Error
            }
        })
    }
    
    func deliverThisVideo(video: AnimalVideo) {
        if video.id.utf16.count == 0 {
            return
        }
        if !isDelivered(video) {
            backgroundSaveObject(video)
        }
    }
    
    private func isDelivered(video: AnimalVideo) -> Bool {
        let items = getAnimalVideos(video.animalName, isEncoded: true)
        if let _ = items.indexOf({$0.id == video.id}) {
            return true
        }
        
        return false
    }
    
    private func backgroundSaveObject(video: AnimalVideo) {
        video.saveInBackgroundWithBlock({ error in
            if error != nil {
                // Error
            }
        })
    }

    func getAnimalVideos(query: String, isEncoded: Bool=false) -> [AnimalVideo] {
        
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
        
        guard let array = self.animalVideoDic[encodedString] else {
            return []
        }
        
        return array
    }

    func search(query: String, aDelegate: NIFTYManagerDelegate?) {
        self.delegate = aDelegate
        
        guard let encodedString = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else {
            return
        }
        
        let q = NCMBQuery(className: AnimalVideo.className())
        q.limit = 200
        // 新着順
        q.orderByDescending("createDate")
        q.whereKey(AnimalVideoKey.animalNameKey, equalTo: encodedString)
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            if error == nil {
                var aArray: [AnimalVideo] = []
                for a in array {
                    
                    if let _a = a as? NCMBObject {
                        if  let i = _a.objectForKey(AnimalVideoKey.idKey) as? String,
                            let ana = _a.objectForKey(AnimalVideoKey.animalNameKey) as? String,
                            let d = _a.objectForKey(AnimalVideoKey.dateKey) as? String,
                            let t = _a.objectForKey(AnimalVideoKey.titleKey) as? String,
                            let th = _a.objectForKey(AnimalVideoKey.thumbnailUrlKey) as? String {
                                
                                let an = AnimalVideo()
                                an.id = i
                                an.animalName = ana
                                an.date = d
                                an.title = t
                                an.thumbnailUrl = th
                                if let de = _a.objectForKey(AnimalVideoKey.descriKey) as? String {
                                    an.descri = de
                                }
                                if let v = _a.objectForKey(AnimalVideoKey.videoUrlKey) as? String {
                                    an.videoUrl = v
                                }
                                an.likeCount = 0
                                if let l = _a.objectForKey(AnimalVideoKey.likeCountKey) as? Int {
                                    an.likeCount = l
                                }
                                
                                aArray.append(an)
                        }
                    }
                }
                self.animalVideoDic[encodedString] = aArray
            }
            self.delegate?.didLoad()
        })
    }
    
    func search(isNew: Bool=false, aDelegate: NIFTYManagerDelegate?) {
        self.delegate = aDelegate
        
        let q = NCMBQuery(className: AnimalVideo.className())
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
                var aArray: [AnimalVideo] = []
                for a in array {
                    
                    if let _a = a as? NCMBObject {
                        if  let i = _a.objectForKey(AnimalVideoKey.idKey) as? String,
                            let ana = _a.objectForKey(AnimalVideoKey.animalNameKey) as? String,
                            let d = _a.objectForKey(AnimalVideoKey.dateKey) as? String,
                            let t = _a.objectForKey(AnimalVideoKey.titleKey) as? String,
                            let th = _a.objectForKey(AnimalVideoKey.thumbnailUrlKey) as? String {
                                
                                let an = AnimalVideo()
                                an.id = i
                                an.animalName = ana
                                an.date = d
                                an.title = t
                                an.thumbnailUrl = th
                                if let de = _a.objectForKey(AnimalVideoKey.descriKey) as? String {
                                    an.descri = de
                                }
                                if let v = _a.objectForKey(AnimalVideoKey.videoUrlKey) as? String {
                                    an.videoUrl = v
                                }
                                an.likeCount = 0
                                if let l = _a.objectForKey(AnimalVideoKey.likeCountKey) as? Int {
                                    an.likeCount = l
                                }
                                
                                aArray.append(an)
                        }
                    }
                }
                let str = isNew ? "New":"Popular"
                self.animalVideoDic[str] = aArray
            }
            self.delegate?.didLoad()
        })
    }

    // Like
    func incrementLike(video: AnimalVideo) {
        // id から LikeObject 撮ってきてインクリメントしてSave
        let q = NCMBQuery(className: AnimalVideo.className())
        q.limit = 1
        q.whereKey(AnimalVideoKey.idKey, equalTo: video.id)
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            if error == nil {
                for a in array {
                    if let _a = a as? NCMBObject {
                        if  let l = _a.objectForKey(AnimalVideoKey.likeCountKey) as? Int,
                            let id = _a.objectForKey(AnimalVideoKey.idKey) as? String {
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
        video.setObject(count+1, forKey: AnimalVideoKey.likeCountKey)
        video.saveInBackgroundWithBlock({ error in
            if error != nil {
                // Error
            }
        })
    }
}
