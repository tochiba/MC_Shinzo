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
        self.accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        getAccounts({ (accounts: [ACAccount]) in
            for a in accounts {
                if a.username == "Subrhyme_" {
                    self.account = a
                }
            }
        })
    }
    
    private func getAccounts(callback: [ACAccount] -> Void) {
        let accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        self.accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError?) -> Void in
            if error != nil {
                // error
                return
            }
            
            if !granted {
                //error Twitterアカウントの利用が許可されていません
                return
            }
            
            let accounts = self.accountStore.accountsWithAccountType(accountType) as! [ACAccount]
            if accounts.count == 0 {
                //error 設定画面からアカウントを設定してください
                return
            }
            
            // アカウント取得完了
            callback(accounts)
        }
    }
    
    private func sendRequest(url: NSURL, requestMethod: SLRequestMethod, params: AnyObject?, responseHandler: (responseData: NSData!, urlResponse: NSHTTPURLResponse!) -> Void) {
        if let twAccount = self.account {
            let request = SLRequest(
                forServiceType: SLServiceTypeTwitter,
                requestMethod: requestMethod,
                URL: url,
                parameters: params as? [NSObject : AnyObject]
            )
            
            request.account = twAccount
            request.performRequestWithHandler { (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
                if error != nil {
                    // error
                } else {
                    responseHandler(responseData: responseData, urlResponse: urlResponse)
                }
            }
        }
    }
    
    func postTweet(video: Video) {
        let shareText = "\(video.title) #Subrhyme \n\(URL.YoutubeShare)\(video.id)\n\(URL.AppStore)"

        if self.account != nil {
            //postTweet(shareText)
            uploadImage(video.thumbnailUrl, message: shareText)
        }
        else {
            getAccounts({ (accounts: [ACAccount]) in
                for a in accounts {
                    if a.username == "Subrhyme_" {
                        self.account = a
                        self.uploadImage(video.thumbnailUrl, message: shareText)
                        //self.postTweet(shareText)
                    }
                }
            })
        }
    }
    
    func uploadImage(imageUrl: String, message: String) {
        if let imageURL = NSURL(string: imageUrl) {
            if let data = NSData(contentsOfURL: imageURL) {
                let base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                let url = NSURL(string: "https://upload.twitter.com/1.1/media/upload.json")!
                let params = ["media_data" : base64String]
                
                sendRequest(url, requestMethod: .POST, params: params) { (responseData, urlResponse) -> Void in
                    do {
                        let jsonObject : AnyObject = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers)
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
        }
    }
    
    func postTweet(msg: String, mediaId: Int? = nil) {
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")!
        var params = ["status" : msg]
        if let mid = mediaId {
            params["media_ids"] = String(mid)
        }
        
        sendRequest(url, requestMethod: .POST, params: params) { (responseData, urlResponse) -> Void in
        }
    }

    func favorite(id id: Int) {
        
        if self.account != nil {
            postFavorite(id: id)
        }
        else {
            getAccounts({ (accounts: [ACAccount]) in
                for a in accounts {
                    if a.username == "Subrhyme_" {
                        self.account = a
                        self.postFavorite(id: id)
                    }
                }
            })
        }
    }
    
    private func postFavorite(id id: Int) {
        let url = NSURL(string: "https://api.twitter.com/1.1/favorites/create.json")!
        let params = ["id" : String(id)]
        
        sendRequest(url, requestMethod: .POST, params: params) { (responseData, urlResponse) -> Void in
        }
    }
    
    func searchTweet(query: String) {
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
    
    func getTweet(query: String) {
        guard let encodedString = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else {
            return
        }
        let url = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")!
        let params = ["q" : encodedString, "lang" : "ja", "result_type" : "recent", "count" : "20"]
        
        sendRequest(url, requestMethod: .GET, params: params) { (responseData, urlResponse) -> Void in
            do {
                let jsonObject : AnyObject = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers)
                let json = JSON(jsonObject)
                for entity in json["statuses"].arrayValue {
                    if let id = entity["id"].int, let favo = entity["favorited"].bool {
                        //favorited
                        if !favo {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                                self.favorite(id: id)
                            })
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
        let queryList: [String] = ["フリースタイルダンジョン", "MCバトル", "高校生ラップ", "フリースタイルラップ", "フリースタイルバトル"]
        for q in queryList {
            getTweet(q)
        }
    }
}
