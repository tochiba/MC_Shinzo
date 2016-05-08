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
    func didFinishLoad()
}

enum SearchMode {
    case Query
    case Channel
    
    var stringUrl: String {
        switch self {
        case .Query:
            return APIURL.YoutubeSearch
        case .Channel:
            return APIURL.YoutubeChanel
        }
    }
}

class APIManager {
    static let sharedInstance = APIManager()
    private var videoDic: [String:[Video]] = [:]
    weak var delegate: SearchAPIManagerDelegate?
    
    func getVideos(query: String) -> [Video] {
        guard let encodedString = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else {
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
    
    func search(query: String, aDelegate: SearchAPIManagerDelegate?, mode: SearchMode = .Query) {
        self.delegate = aDelegate
        guard let encodedString = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else {
            return
        }
        
        Alamofire.request(.GET, mode.stringUrl + encodedString + APIPARAM.Token + APITOKEN.YoutubeToken)
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
                }
                
                self.videoDic[encodedString] = videos
                self.delegate?.didFinishLoad()
        }
    }
    
    func nextSearch(query: String, nextToken: String, aArray: [Video], mode: SearchMode) {
        var _aArray = aArray
        Alamofire.request(.GET, mode.stringUrl + query + APIPARAM.Token + APITOKEN.YoutubeToken + APIPARAM.NextPageToken + nextToken)
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
                }
                
                self.videoDic[query] = _aArray
                self.delegate?.didFinishLoad()
        }
    }

}

struct APIURL {
    static let YoutubeSearch = "https://www.googleapis.com/youtube/v3/search?part=id,snippet&maxResults=50&order=date&q="
    static let YoutubeNextSearch = "https://www.googleapis.com/youtube/v3/search?part=id,snippet&maxResults=50&order=date&q="
    static let YoutubeChanel = "https://www.googleapis.com/youtube/v3/search?part=id,snippet&maxResults=50&order=date&channelId="
}

struct APIPARAM {
    static let Token            = "&key="
    static let NextPageToken    = "&pageToken="
}
