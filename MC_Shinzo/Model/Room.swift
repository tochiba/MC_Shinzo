//
//  Room.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/06/26.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB

class Room: NCMBObject, NSCoding {
    class func className() -> String {
        return "Room"
    }
    var videoId: String = "" {
        didSet {
            self.setObject(videoId, forKey: VideoKey.idKey)
        }
    }
    var commentCount: Int = 0 {
        didSet {
            self.setObject(commentCount, forKey: RoomKey.commentCount)
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
        if let cc = aDecoder.decodeObject(forKey: RoomKey.commentCount) as? Int {
            self.commentCount = cc
            self.setObject(cc, forKey: RoomKey.commentCount)
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(videoId, forKey: VideoKey.idKey)
        aCoder.encode(commentCount, forKey: RoomKey.commentCount)
    }
}
struct RoomKey {
    static let commentCount: String = "commentCount"
}
