//
//  UserManager.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/06/26.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB

protocol UserManagerDelegate: class {
    func refreshUserInfo()
}

class UserManager {
    static let sharedInstance = UserManager()
    var delegate: UserManagerDelegate?
    
    struct Keys {
        static let saveUser = "UserKey"
    }
    
    func saveUser(user: User) {
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(user)
        NSUserDefaults.standardUserDefaults().setObject(encodedData, forKey: Keys.saveUser)
        NSUserDefaults.standardUserDefaults().synchronize()
        self.delegate?.refreshUserInfo()
    }
    
    func getUser() -> User {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(Keys.saveUser) as? NSData {
            if let user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? User {
                return user
            }
        }
        
        let _user = User()
        _user.id = NSUUID().UUIDString
        saveUser(_user)
        return _user
    }
    
    func uploadUserImage(userID: String, data: NSData) -> String {
        let fileName = userID + ".jpg"
        var error: NSError?
        let file = NCMBFile.fileWithName(fileName, data: data)
        file.save(&error)
        return fileName
    }
    
    func getUserImage(userID: String) -> NSData {
        let fileName = userID
        if let file = NCMBFile.fileWithName(fileName, data: nil) as? NCMBFile {
            return file.getFileData()
        }
        
        return NSData()
    }
}

public extension NCMBFile {
    public func getFileData() -> NSData {
        let request = NCMBURLConnection(path: "files/\(self.name)", method: "GET", data: nil)
        
        do {
            if let responseData = try request.syncConnection() as? NSData {
                return responseData
            }
        }
        catch {}
        
        return NSData()
    }
}
