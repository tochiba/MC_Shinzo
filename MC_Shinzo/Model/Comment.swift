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
    var dateInt: Int = 0 {
        didSet {
            self.setObject(dateInt, forKey: CommentKey.date)
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
        
        if let vi = aDecoder.decodeObject(forKey: VideoKey.idKey) as? String {
            self.videoId = vi
            self.setObject(vi, forKey: VideoKey.idKey)
        }
        if let sn = aDecoder.decodeObject(forKey: CommentKey.senderName) as? String {
            self.senderName = sn
            self.setObject(sn, forKey: CommentKey.senderName)
        }
        if let si = aDecoder.decodeObject(forKey: CommentKey.senderId) as? String {
            self.senderId = si
            self.setObject(si, forKey: CommentKey.senderId)
        }
        if let d = aDecoder.decodeObject(forKey: CommentKey.date) as? Int {
            self.dateInt = d
            self.setObject(d, forKey: CommentKey.date)
        }
        if let t = aDecoder.decodeObject(forKey: CommentKey.text) as? String {
            self.text = t
            self.setObject(t, forKey: CommentKey.text)
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(videoId, forKey: VideoKey.idKey)
        aCoder.encode(senderName, forKey: CommentKey.senderName)
        aCoder.encode(senderId, forKey: CommentKey.senderId)
        aCoder.encode(dateInt, forKey: CommentKey.date)
        aCoder.encode(text, forKey: CommentKey.text)
        
    }
}
struct CommentKey {
    static let senderName: String = "senderName"
    static let senderId: String = "senderId"
    static let date: String = "date"
    static let text: String = "text"
}
