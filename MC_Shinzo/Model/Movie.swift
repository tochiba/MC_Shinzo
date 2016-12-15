//
//  Movie.swift
//  MC_Shinzo
//
//  Created by tochiba on 2016/03/30.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB

class IllegalVideo: NCMBObject {
    var id: String              = "" {
        didSet {
            self.setObject(id, forKey: VideoKey.idKey)
        }
    }
    var categoryName: String      = "" {
        didSet {
            self.setObject(categoryName, forKey: VideoKey.categoryNameKey)
        }
    }
    var date: String            = "" {
        didSet {
            self.setObject(date, forKey: VideoKey.dateKey)
        }
    }
    var title: String           = "" {
        didSet {
            self.setObject(title, forKey: VideoKey.titleKey)
        }
    }

    class func className() -> String {
        return "IllegalVideo"
    }
    override init() {
        super.init(className: IllegalVideo.className())
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(className: IllegalVideo.className())
    }
}

class Video: NCMBObject, NSCoding {

    class func className() -> String {
        return "Video"
    }
    
    var id: String              = "" {
        didSet {
            self.setObject(id, forKey: VideoKey.idKey)
        }
    }

    var categoryName: String      = "" {
        didSet {
            self.setObject(categoryName, forKey: VideoKey.categoryNameKey)
        }
    }

    var date: String            = "" {
        didSet {
            self.setObject(date, forKey: VideoKey.dateKey)
        }
    }

    var title: String           = "" {
        didSet {
            self.setObject(title, forKey: VideoKey.titleKey)
        }
    }

    var descri: String    = "" {
        didSet {
            self.setObject(descri, forKey: VideoKey.descriKey)
        }
    }

    var thumbnailUrl: String    = "" {
        didSet {
            self.setObject(thumbnailUrl, forKey: VideoKey.thumbnailUrlKey)
        }
    }

    var videoUrl: String        = "" {
        didSet {
            self.setObject(videoUrl, forKey: VideoKey.videoUrlKey)
        }
    }
    
    var likeCount: Int          = 0 {
        didSet {
            self.setObject(likeCount, forKey: VideoKey.likeCountKey)
        }
    }
    
    var channelName: String        = "" {
        didSet {
            self.setObject(channelName, forKey: VideoKey.channelNameKey)
        }
    }

    var channelId: String        = "" {
        didSet {
            self.setObject(channelId, forKey: VideoKey.channelIdKey)
        }
    }
    
    var dateInteger: Int         = 0 {
        didSet {
            self.setObject(dateInteger, forKey: VideoKey.dateIntegerKey)
        }
    }

    
    override init() {
        super.init(className: Video.className())
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(className: Video.className())
        
        if let i = aDecoder.decodeObject(forKey: VideoKey.idKey) as? String {
            self.id = i
            self.setObject(i, forKey: VideoKey.idKey)
        }
        if let a = aDecoder.decodeObject(forKey: VideoKey.categoryNameKey) as? String {
            self.categoryName = a
            self.setObject(a, forKey: VideoKey.categoryNameKey)
        }
        if let date = aDecoder.decodeObject(forKey: VideoKey.dateKey) as? String {
            self.date = date
            self.setObject(date, forKey: VideoKey.dateKey)
        }
        if let title = aDecoder.decodeObject(forKey: VideoKey.titleKey) as? String {
            self.title = title
            self.setObject(title, forKey: VideoKey.titleKey)
        }
        if let d = aDecoder.decodeObject(forKey: VideoKey.descriKey) as? String {
            self.descri = d
            self.setObject(d, forKey: VideoKey.descriKey)
        }
        if let t = aDecoder.decodeObject(forKey: VideoKey.thumbnailUrlKey) as? String {
            self.thumbnailUrl = t
            self.setObject(t, forKey: VideoKey.thumbnailUrlKey)
        }
        if let v = aDecoder.decodeObject(forKey: VideoKey.videoUrlKey) as? String {
            self.videoUrl = v
            self.setObject(v, forKey: VideoKey.videoUrlKey)
        }
        if let l = aDecoder.decodeObject(forKey: VideoKey.likeCountKey) as? Int {
            self.likeCount = l
            self.setObject(l, forKey: VideoKey.likeCountKey)
        }
        if let cn = aDecoder.decodeObject(forKey: VideoKey.channelNameKey) as? String {
            self.channelName = cn
            self.setObject(cn, forKey: VideoKey.channelNameKey)
        }
        if let ci = aDecoder.decodeObject(forKey: VideoKey.channelIdKey) as? String {
            self.channelId = ci
            self.setObject(ci, forKey: VideoKey.channelIdKey)
        }
        if let di = aDecoder.decodeObject(forKey: VideoKey.dateIntegerKey) as? Int {
            self.dateInteger = di
            self.setObject(di, forKey: VideoKey.dateIntegerKey)
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: VideoKey.idKey)
        aCoder.encode(categoryName, forKey: VideoKey.categoryNameKey)
        aCoder.encode(date, forKey: VideoKey.dateKey)
        aCoder.encode(title, forKey: VideoKey.titleKey)
        aCoder.encode(descri, forKey: VideoKey.descriKey)
        aCoder.encode(thumbnailUrl, forKey: VideoKey.thumbnailUrlKey)
        aCoder.encode(videoUrl, forKey: VideoKey.videoUrlKey)
        aCoder.encode(likeCount, forKey: VideoKey.likeCountKey)
        aCoder.encode(channelName, forKey: VideoKey.channelNameKey)
        aCoder.encode(channelId, forKey: VideoKey.channelIdKey)
        aCoder.encode(dateInteger, forKey: VideoKey.dateIntegerKey)
    }
}

struct VideoKey {
    static let idKey: String              = "id"
    static let categoryNameKey: String    = "categoryName"
    static let dateKey: String            = "date"
    static let titleKey: String           = "title"
    static let descriKey: String          = "descri"
    static let thumbnailUrlKey: String    = "thumbnailUrl"
    static let videoUrlKey: String        = "videoUrl"
    static let likeCountKey: String       = "likeCount"
    static let channelNameKey: String     = "channelName"
    static let channelIdKey: String       = "channelId"
    static let dateIntegerKey: String     = "dateInteger"
}


class Channel: NCMBObject {
    var channelName: String        = "" {
        didSet {
            self.setObject(channelName, forKey: VideoKey.channelNameKey)
        }
    }
    var channelId: String        = "" {
        didSet {
            self.setObject(channelId, forKey: VideoKey.channelIdKey)
        }
    }
    
    class func className() -> String {
        return "Channel"
    }
    override init() {
        super.init(className: Channel.className())
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(className: Channel.className())
    }
}

