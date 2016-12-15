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
    
    func saveUser(_ user: User) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(encodedData, forKey: Keys.saveUser)
        UserDefaults.standard.synchronize()
        self.delegate?.refreshUserInfo()
    }
    
    func getUser() -> User {
        if let data = UserDefaults.standard.object(forKey: Keys.saveUser) as? Data {
            if let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? User {
                return user
            }
        }
        
        let _user = User()
        _user.id = UUID().uuidString
        saveUser(_user)
        return _user
    }
    
    func uploadUserImage(_ userID: String, data: Data) -> String {
        let fileName = userID + ".jpg"
        var error: NSError?
        if let file = NCMBFile.file(withName: fileName, data: data) as? NCMBObject {
            file.save(&error)
        }
        return fileName
    }
    
    func getUserImage(_ userID: String) -> Data {
        let fileName = userID
        if let file = NCMBFile.file(withName: fileName, data: nil) as? NCMBFile {
            return file.getFileData()
        }
        
        return Data()
    }
}

public extension NCMBFile {
    public func getFileData() -> Data {
        let request = NCMBURLConnection(path: "files/\(self.name)", method: "GET", data: nil)
        
        do {
            if let responseData = try request?.syncConnection() as? Data {
                return responseData
            }
        }
        catch {}
        
        return Data()
    }
}
