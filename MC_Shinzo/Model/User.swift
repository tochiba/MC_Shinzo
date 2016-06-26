//
//  User.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/06/26.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB

class User: NCMBObject, NSCoding {
    class func className() -> String {
        return "User"
    }
    var id: String = "" {
        didSet {
            self.setObject(id, forKey: UserKey.id)
        }
    }
    var name: String = "匿名" {
        didSet {
            self.setObject(name, forKey: UserKey.name)
        }
    }
    var image: String = "" {
        didSet {
            self.setObject(image, forKey: UserKey.image)
        }
    }
    
    override init() {
        super.init(className: User.className())
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(className: User.className())
        
        if let i = aDecoder.decodeObjectForKey(UserKey.id) as? String {
            self.id = i
        }
        if let n = aDecoder.decodeObjectForKey(UserKey.name) as? String {
            self.name = n
        }
        if let im = aDecoder.decodeObjectForKey(UserKey.image) as? String {
            self.image = im
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: UserKey.id)
        aCoder.encodeObject(name, forKey: UserKey.name)
        aCoder.encodeObject(image, forKey: UserKey.image)
    }
}

struct UserKey {
    static let id: String    = "id"
    static let name: String  = "title"
    static let image: String = "image"
}
