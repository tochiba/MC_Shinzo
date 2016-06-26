//
//  Comment.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/06/26.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB

class Comment: NCMBObject, NSCoding {
    class func className() -> String {
        return "Comment"
    }
    var videoId: String = "" {
        didSet {
            self.setObject(videoId, forKey: VideoKey.idKey)
        }
    }
    var senderName: String = "" {
        didSet {
            self.setObject(senderName, forKey: CommentKey.senderName)
        }
    }
    var senderId: String = "" {
        didSet {
            self.setObject(senderId, forKey: CommentKey.senderId)
        }
    }
    var date: String  = "" {
        didSet {
            self.setObject(date, forKey: CommentKey.date)
        }
    }
    var text: String  = "" {
        didSet {
            self.setObject(text, forKey: CommentKey.text)
        }
    }
    override init() {
        super.init(className: Room.className())
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(className: Room.className())
        
        if let vi = aDecoder.decodeObjectForKey(VideoKey.idKey) as? String {
            self.videoId = vi
            self.setObject(vi, forKey: VideoKey.idKey)
        }
        if let sn = aDecoder.decodeObjectForKey(CommentKey.senderName) as? String {
            self.senderName = sn
            self.setObject(sn, forKey: CommentKey.senderName)
        }
        if let si = aDecoder.decodeObjectForKey(CommentKey.senderId) as? String {
            self.senderId = si
            self.setObject(si, forKey: CommentKey.senderId)
        }
        if let d = aDecoder.decodeObjectForKey(CommentKey.date) as? String {
            self.date = d
            self.setObject(d, forKey: CommentKey.date)
        }
        if let t = aDecoder.decodeObjectForKey(CommentKey.text) as? String {
            self.text = t
            self.setObject(t, forKey: CommentKey.text)
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(videoId, forKey: VideoKey.idKey)
        aCoder.encodeObject(senderName, forKey: CommentKey.senderName)
        aCoder.encodeObject(senderId, forKey: CommentKey.senderId)
        aCoder.encodeObject(date, forKey: CommentKey.date)
        aCoder.encodeObject(text, forKey: CommentKey.text)
        
    }
}
struct CommentKey {
    static let senderName: String = "senderName"
    static let senderId: String = "senderId"
    static let date: String = "date"
    static let text: String = "text"
}
