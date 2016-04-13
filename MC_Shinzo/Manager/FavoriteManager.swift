//
//  FavoriteManager.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/04/09.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

protocol FavoriteManagerDelegate: class {
    func didLoadFavoriteData()
}

class FavoriteManager {
    static let sharedInstance = FavoriteManager()
    
    private var Videos: [Video] = []
    weak var delegate: FavoriteManagerDelegate?
    
    init() {
        load()
    }
    
    func load(delegate: FavoriteManagerDelegate?=nil) {
        self.delegate = delegate
        do {
            let realm = try Realm()
            var _array: [Video] = []
            for f in realm.objects(FavoriteVideo) {
                _array.append(convert(f))
            }
            self.Videos = _array
            self.delegate?.didLoadFavoriteData()
        }
        catch _ as NSError {
        }
    }
    
    func getFavoriteVideos() -> [Video] {
        return self.Videos.reverse()
    }
    func isFavoriteVideo(id: String) -> Bool {
        if let _ = self.Videos.indexOf({$0.id == id}) {
            return true
        }
        
        return false
    }
    
    func addFavoriteVideo(video: Video) {
        if let _ = self.Videos.indexOf({$0.id == video.id}) {
            return
        }
        
        do {
            let realm = try Realm()
            try! realm.write {
                realm.add(convert(video))
            }
        }
        catch _ as NSError {
        }
        load()
    }
    
    func removeFavoriteVideo(video: Video) {        
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "id == '\(video.id)'")
            if let _target = realm.objects(FavoriteVideo).filter(predicate).first {
                try! realm.write {
                    realm.delete(_target)
                }
            }
        }
        catch _ as NSError {
        }
        
        load()
    }
    
    private func convert(fVideo: FavoriteVideo) -> Video {
        let a = Video()
        a.id = fVideo.id
        a.categoryName = fVideo.categoryName
        a.date = fVideo.date
        a.title = fVideo.title
        a.thumbnailUrl = fVideo.thumbnailUrl
        a.descri = fVideo.descri
        a.videoUrl = fVideo.videoUrl
        a.likeCount = fVideo.likeCount
        
        return a
    }

    private func convert(aVideo: Video) -> FavoriteVideo {
        let f = FavoriteVideo()
        f.id = aVideo.id
        f.categoryName = aVideo.categoryName
        f.date = aVideo.date
        f.title = aVideo.title
        f.thumbnailUrl = aVideo.thumbnailUrl
        f.descri = aVideo.descri
        f.videoUrl = aVideo.videoUrl
        f.likeCount = aVideo.likeCount
        
        return f
    }
}

class FavoriteVideo: Object {
    dynamic var id: String              = ""
    dynamic var categoryName: String      = ""
    dynamic var date: String            = ""
    dynamic var title: String           = ""
    dynamic var descri: String          = ""
    dynamic var thumbnailUrl: String    = ""
    dynamic var videoUrl: String        = ""
    dynamic var likeCount: Int          = 0
}
