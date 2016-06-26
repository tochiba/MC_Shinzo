//
//  CommentManager.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/06/26.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB

class CommentManager {
    static let sharedInstance = CommentManager()
    // TODO:
    func getComments(videoId videoId: String) {
    }
    // TODO: Userクラス必要かな
    func addComment(text text: String, videoId: String) {
        // saveComment
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

}