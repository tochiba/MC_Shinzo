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
    
    private var animalVideos: [AnimalVideo] = []
    weak var delegate: FavoriteManagerDelegate?
    
    init() {
        load()
    }
    
    func load(delegate: FavoriteManagerDelegate?=nil) {
        self.delegate = delegate
        do {
            let realm = try Realm()
            var _array: [AnimalVideo] = []
            for f in realm.objects(FavoriteAnimalVideo) {
                _array.append(convert(f))
            }
            self.animalVideos = _array
            self.delegate?.didLoadFavoriteData()
        }
        catch _ as NSError {
        }
    }
    
    func getFavoriteVideos() -> [AnimalVideo] {
        return self.animalVideos.reverse()
    }
    func isFavoriteVideo(id: String) -> Bool {
        if let _ = self.animalVideos.indexOf({$0.id == id}) {
            return true
        }
        
        return false
    }
    
    func addFavoriteVideo(video: AnimalVideo) {
        if let _ = self.animalVideos.indexOf({$0.id == video.id}) {
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
    
    func removeFavoriteVideo(video: AnimalVideo) {        
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "id == '\(video.id)'")
            if let _target = realm.objects(FavoriteAnimalVideo).filter(predicate).first {
                try! realm.write {
                    realm.delete(_target)
                }
            }
        }
        catch _ as NSError {
        }
        
        load()
    }
    
    private func convert(fVideo: FavoriteAnimalVideo) -> AnimalVideo {
        let a = AnimalVideo()
        a.id = fVideo.id
        a.animalName = fVideo.animalName
        a.date = fVideo.date
        a.title = fVideo.title
        a.thumbnailUrl = fVideo.thumbnailUrl
        a.descri = fVideo.descri
        a.videoUrl = fVideo.videoUrl
        a.likeCount = fVideo.likeCount
        
        return a
    }

    private func convert(aVideo: AnimalVideo) -> FavoriteAnimalVideo {
        let f = FavoriteAnimalVideo()
        f.id = aVideo.id
        f.animalName = aVideo.animalName
        f.date = aVideo.date
        f.title = aVideo.title
        f.thumbnailUrl = aVideo.thumbnailUrl
        f.descri = aVideo.descri
        f.videoUrl = aVideo.videoUrl
        f.likeCount = aVideo.likeCount
        
        return f
    }
}

class FavoriteAnimalVideo: Object {
    dynamic var id: String              = ""
    dynamic var animalName: String      = ""
    dynamic var date: String            = ""
    dynamic var title: String           = ""
    dynamic var descri: String          = ""
    dynamic var thumbnailUrl: String    = ""
    dynamic var videoUrl: String        = ""
    dynamic var likeCount: Int          = 0
}
