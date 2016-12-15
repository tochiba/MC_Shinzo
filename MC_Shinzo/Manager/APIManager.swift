//
//  APIManager.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/03/27.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import NCMB

protocol SearchAPIManagerDelegate: class {
    func didFinishLoad(_ videos: [Video])
}

enum SearchMode {
    case query
    case channel
    
    var stringUrl: String {
        switch self {
        case .query:
            return APIURL.YoutubeSearch
        case .channel:
            return APIURL.YoutubeChanel
        }
    }
}

class APIManager {
    static let sharedInstance = APIManager()
    fileprivate var videoDic: [String:[Video]] = [:]
    weak var delegate: SearchAPIManagerDelegate?
    
    func getVideos(_ query: String) -> [Video] {
        guard let encodedString = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return []
        }
        
        guard let array = self.videoDic[encodedString] else {
            return []
        }
        
        var _array: [Video] = []
        for a in array {
            if !NIFTYManager.sharedInstance.isDeliveredVideo(a) {
                _array.append(a)
            }
        }
        return _array
    }
    
    func search(_ query: String, aDelegate: SearchAPIManagerDelegate?, mode: SearchMode = .query) {
        self.delegate = aDelegate
        guard let encodedString = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return
        }
        
        Alamofire.request(mode.stringUrl + encodedString + APIPARAM.Token + APITOKEN.YoutubeToken, method: .get)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                
                let json = JSON(object)
                guard let array = json["items"].array else {
                    return
                }

                var videos: [Video] = []
                for i in array {
                    let a = Video()
                    a.categoryName = encodedString
                    a.id = i["id"]["videoId"].stringValue
                    a.date = i["snippet"]["publishedAt"].stringValue
                    a.title = i["snippet"]["title"].stringValue
                    a.descri = i["snippet"]["description"].stringValue
                    a.thumbnailUrl = i["snippet"]["thumbnails"]["high"]["url"].stringValue
                    a.likeCount = 1
                    a.channelName = i["snippet"]["channelTitle"].stringValue
                    a.channelId = i["snippet"]["channelId"].stringValue
                    if a.id != "" {
                        videos.append(a)
                    }
                }
                
                if let ntoken = json["nextPageToken"].string {
                    self.nextSearch(encodedString, nextToken: ntoken, aArray: videos, mode: mode)
                    return
                }
                
                self.videoDic[encodedString] = videos
                self.delegate?.didFinishLoad(videos)
        }
    }
    
    func nextSearch(_ query: String, nextToken: String, aArray: [Video], mode: SearchMode) {
        var _aArray = aArray
        Alamofire.request(mode.stringUrl + query + APIPARAM.Token + APITOKEN.YoutubeToken + APIPARAM.NextPageToken + nextToken, method: .get)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                
                let json = JSON(object)
                guard let _array = json["items"].array else {
                    return
                }
                
                for i in _array {
                    let a = Video()
                    a.categoryName = query
                    a.id = i["id"]["videoId"].stringValue
                    a.date = i["snippet"]["publishedAt"].stringValue
                    a.title = i["snippet"]["title"].stringValue
                    a.descri = i["snippet"]["description"].stringValue
                    a.thumbnailUrl = i["snippet"]["thumbnails"]["high"]["url"].stringValue
                    a.likeCount = 1
                    a.channelName = i["snippet"]["channelTitle"].stringValue
                    a.channelId = i["snippet"]["channelId"].stringValue
                    if a.id != "" {
                        _aArray.append(a)
                    }
                }
                
                if let ntoken = json["nextPageToken"].string {
                    self.nextSearch(query, nextToken: ntoken, aArray: _aArray, mode: mode)
                    return
                }
                
                self.videoDic[query] = _aArray
                self.delegate?.didFinishLoad(_aArray)
        }
    }

    func postNotification(_ video: Video) {
        let text = "【新着動画】\(video.title)がアップロードされました"
        let param = ["app_id": APP_ID.OneSignal,
                     "contents": ["en": text],
                     "included_segments": ["All"],
                     "ios_badgeType": "Increase"] as [String : Any];
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Basic \(API_KEY.OneSignal)"
        ]
        Alamofire.request("https://onesignal.com/api/v1/notifications", method: .post, parameters: param, headers: headers).responseJSON { response in
        }
//        Alamofire.request("https://onesignal.com/api/v1/notifications", method: .post, parameters: param as? [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
//        }
    }
}

extension APIManager {
    func videoCheckSearch(_ video: Video) {
        Alamofire.request(APIURL.YoutubeVideoSearch + video.id + APIPARAM.Token + APITOKEN.YoutubeToken, method: .get)
            .responseJSON { response in
                
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                guard let _array = json["items"].array else {
                    return
                }
                for i in _array {
                    if let s = i["status"]["uploadStatus"].string, s != "processed" {
                        NIFTYManager.sharedInstance.deleteThisVideo(video)
                    }
                }
        }
    }
}

struct APIURL {
    static let YoutubeSearch = "https://www.googleapis.com/youtube/v3/search?part=id,snippet&maxResults=50&order=date&q="
    static let YoutubeNextSearch = "https://www.googleapis.com/youtube/v3/search?part=id,snippet&maxResults=50&order=date&q="
    static let YoutubeChanel = "https://www.googleapis.com/youtube/v3/search?part=id,snippet&maxResults=50&order=date&channelId="
    static let YoutubeVideoSearch = "https://www.googleapis.com/youtube/v3/videos?part=id,snippet,status&maxResults=1&order=date&id="
}

struct APIPARAM {
    static let Token            = "&key="
    static let NextPageToken    = "&pageToken="
}
