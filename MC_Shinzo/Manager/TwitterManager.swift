//
//  TwitterManager.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/05/19.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import Accounts
import Social
import SwiftyJSON

class TwitterManager {
    static let sharedInstance = TwitterManager()
    var accountStore = ACAccountStore()
    var accountType: ACAccountType
    var account: ACAccount?
    
    init() {
        self.accountType = self.accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        getAccounts({ (accounts: [ACAccount]) in
            for a in accounts {
                if a.username == "Subrhyme_" {
                    self.account = a
                }
            }
        })
    }
    
    fileprivate func getAccounts(_ callback: @escaping ([ACAccount]) -> Void) {
        let accountType = self.accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        self.accountStore.requestAccessToAccounts(with: accountType, options: nil, completion: { (granted: Bool, error: Error?) -> Swift.Void in
            if error != nil {
                // error
                return
            }
            
            if !granted {
                //error Twitterアカウントの利用が許可されていません
                return
            }
            
            let accounts = self.accountStore.accounts(with: accountType) as! [ACAccount]
            if accounts.count == 0 {
                //error 設定画面からアカウントを設定してください
                return
            }
            
            // アカウント取得完了
            callback(accounts)
        })
    }
    
    fileprivate func sendRequest(_ url: Foundation.URL, requestMethod: SLRequestMethod, params: AnyObject?, responseHandler: @escaping (_ responseData: NSData?, _ urlResponse: HTTPURLResponse?) -> Void) {
        if let twAccount = self.account {
            let request = SLRequest(
                forServiceType: SLServiceTypeTwitter,
                requestMethod: requestMethod,
                url: url,
                parameters: params as? [AnyHashable: Any]
            )
            
            request?.account = twAccount
            
            let handler = {(responseData: Data?, urlResponse: HTTPURLResponse?, error: Error?) -> Swift.Void in
                if error != nil {
                    // error
                } else {
                    responseHandler(responseData as NSData?, urlResponse)
                }
            }
            request?.perform(handler: handler)
        }
    }
    
    func postTweet(_ video: Video) {
        let shareText = "\(video.title) #Subrhyme \n\(URL.YoutubeShare)\(video.id)\n\(URL.AppStore)"
        
        getAccounts({ (accounts: [ACAccount]) in
            for a in accounts {
                if a.username == "Subrhyme_" {
                    self.account = a
                    self.uploadImage(video.thumbnailUrl, message: shareText)
                }
            }
        })
    }
    
    func uploadImage(_ imageUrl: String, message: String) {
        if let imageURL = Foundation.URL(string: imageUrl) {
            do {
                let data = try Data(contentsOf: imageURL)
                let base64String = data.base64EncodedString(options: .lineLength64Characters)
                let url = Foundation.URL(string: "https://upload.twitter.com/1.1/media/upload.json")!
                let params = ["media_data" : base64String]
                sendRequest(url, requestMethod: .POST, params: params as AnyObject?) { (responseData, urlResponse) -> Void in
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: responseData as! Data, options: JSONSerialization.ReadingOptions.mutableContainers)
                        let json = JSON(jsonObject)
                        if let id = json["media_id"].int {
                            self.postTweet(message, mediaId: id)
                        }
                    }
                    catch {
                        self.postTweet(message)
                        return
                    }
                }
            }
            catch {
                return
            }
        }
    }
    
    func postTweet(_ msg: String, mediaId: Int? = nil) {
        let url = Foundation.URL(string: "https://api.twitter.com/1.1/statuses/update.json")!
        var params = ["status" : msg]
        if let mid = mediaId {
            params["media_ids"] = String(mid)
        }
        
        sendRequest(url, requestMethod: .POST, params: params as AnyObject?) { (responseData, urlResponse) -> Void in
        }
    }

    func favorite(_ id: Int) {
        if self.account != nil {
            postFavorite(id)
        }
        else {
            getAccounts({ (accounts: [ACAccount]) in
                for a in accounts {
                    if a.username == "Subrhyme_" {
                        self.account = a
                        self.postFavorite(id)
                    }
                }
            })
        }
    }
    
    fileprivate func postFavorite(_ id: Int) {
        let url = Foundation.URL(string: "https://api.twitter.com/1.1/favorites/create.json")!
        let params = ["id" : String(id)]
        print("Check Twitter: \(Date()) Favo ID: \(String(id))")
        sendRequest(url, requestMethod: .POST, params: params as AnyObject?) { (responseData, urlResponse) -> Void in
            do {
            let jsonObject = try JSONSerialization.jsonObject(with: responseData as! Data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let json = JSON(jsonObject)
                print(json)
            }
            catch {}
            
        }
    }
    
    func searchTweet(_ query: String) {
        if self.account != nil {
            getTweet(query)
        }
        else {
            getAccounts({ (accounts: [ACAccount]) in
                for a in accounts {
                    if a.username == "Subrhyme_" {
                        self.account = a
                        self.getTweet(query)
                    }
                }
            })
        }
    }
    
    func getTweet(_ query: String) {
        guard let encodedString = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return
        }
        let url = Foundation.URL(string: "https://api.twitter.com/1.1/search/tweets.json")!
        let params = ["q" : encodedString, "lang" : "ja", "result_type" : "recent", "count" : "5"]
        
        sendRequest(url, requestMethod: .GET, params: params as AnyObject?) { (responseData, urlResponse) -> Void in
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: responseData as! Data, options: JSONSerialization.ReadingOptions.mutableContainers)
                let json = JSON(jsonObject)
                for entity in json["statuses"].arrayValue {
                    if let id = entity["id"].int, let favo = entity["favorited"].bool {
                        //favorited
                        if !favo {
                            self.favorite(id)
                        }
                    }
                }
            }
            catch {
                return
            }
        }
    }

    
    func startAutoFavorite() {
        let queryList: [String] = ["フリースタイルダンジョン", "MCバトル", "高校生ラップ"]//, "フリースタイルラップ", "フリースタイルバトル"]
        
        getAccounts({ (accounts: [ACAccount]) in
            for a in accounts {
                if a.username == "Subrhyme_" {
                    self.account = a
                    for q in queryList {
                        self.getTweet(q)
                    }
                }
            }
        })
        
    }
}
