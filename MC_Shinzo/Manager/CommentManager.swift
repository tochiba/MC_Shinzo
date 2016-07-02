//
//  CommentManager.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/06/26.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB

protocol CommentManagerDelegate: class {
    func loadComment(videoId: String, comments: [Comment])
}

class CommentManager {
    static let sharedInstance = CommentManager()
    private var commentDic: [String:[Comment]] = [:]

    func getComments(videoId videoId: String, delegate: CommentManagerDelegate?) {
        weak var weakDelegate = delegate
        if let c = commentDic[videoId] {
            weakDelegate?.loadComment(videoId, comments: c)
        }
        
        let q = NCMBQuery(className: Comment.className())
        q.limit = 1000
        q.whereKey(VideoKey.idKey, equalTo: videoId)
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            var clist: [Comment] = []
            for a in array {
                if let _a = a as? NCMBObject {
                    if  let vi = _a.objectForKey(VideoKey.idKey) as? String,
                        let sn = _a.objectForKey(CommentKey.senderName) as? String,
                        let si = _a.objectForKey(CommentKey.senderId) as? String,
                        let d  = _a.objectForKey(CommentKey.date) as? Int,
                        let t  = _a.objectForKey(CommentKey.text) as? String {
                        
                        let c = Comment()
                        c.videoId = vi
                        c.senderName = sn
                        c.senderId = si
                        c.dateInt = d
                        c.text = t
                        clist.append(c)
                    }
                }
            }
            self.commentDic[videoId] = clist
            weakDelegate?.loadComment(videoId, comments: clist)
        })
    }

    func addComment(text text: String, videoId: String) {
        let u = UserManager.sharedInstance.getUser()
        let c = Comment()
        c.videoId = videoId
        c.senderName = u.name
        c.senderId = u.id
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        if  let i = Int(dateFormatter.stringFromDate(date)) {
            c.dateInt = i
        }
        c.text = text
        saveComment(c)
    }
    
    private func saveComment(c: Comment) {
        if c.videoId.utf16.count == 0 {
            return
        }
        
        let q = NCMBQuery(className: Comment.className())
        q.limit = 1
        q.whereKey(VideoKey.idKey, equalTo: c.videoId)//配信済みかチェックするため
        q.whereKey(CommentKey.text, equalTo: c.text)
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            //配信済みかチェック
            if error == nil && array.count == 0 {
                c.saveInBackgroundWithBlock({ error in
                    if error == nil {
                        self.incrementCommentCount(c.videoId)
                    }
                })
            }
            
        })
    }
    
    private func incrementCommentCount(videoId: String) {
        let q = NCMBQuery(className: Room.className())
        q.limit = 1
        q.whereKey(VideoKey.idKey, equalTo: videoId)
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            //配信済みかチェック
            if error == nil {
                if array.count == 0 {
                    let r = Room()
                    r.videoId = videoId
                    r.commentCount = 1
                    r.saveInBackgroundWithBlock({ error in
                        if error != nil {}
                    })
                }
                else {
                    for a in array {
                        if let _a = a as? NCMBObject {
                            if  let l = _a.objectForKey(RoomKey.commentCount) as? Int,
                                let id = _a.objectForKey(VideoKey.idKey) as? String {
                                if id.utf16.count == 0 {
                                    return
                                }
                                self.setRoomCommentCount(_a, count: l)
                            }
                        }
                    }
                }
            }
            
        })
    }
    
    private func setRoomCommentCount(room: NCMBObject, count: Int) {
        room.setObject(count+1, forKey: RoomKey.commentCount)
        room.saveInBackgroundWithBlock({ error in
            if error != nil {}
        })
    }
    
    // TODO: illigal comment
}