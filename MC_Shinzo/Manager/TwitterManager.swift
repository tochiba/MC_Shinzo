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
    
    func postTweet(msg: String) {
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")!
        let params = ["status" : msg]
        
        sendRequest(url, requestMethod: .POST, params: params) { (responseData, urlResponse) -> Void in
            // 投稿完了ハンドラ
            //print(responseData)
        }
    }
    
    func postTweet(video: Video) {
        let shareText = "\(video.title) #Subrhyme \n\(URL.YoutubeShare)\(video.id)\n\(URL.AppStore)"

        if self.account != nil {
            postTweet(shareText)
        }
        else {
            getAccounts({ (accounts: [ACAccount]) in
                for a in accounts {
                    if a.username == "Subrhyme_" {
                        self.account = a
                        self.postTweet(shareText)
                    }
                }
            })
        }
        
    }
}
