//
//  CardCollectionCell.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/04/10.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit

protocol CardCollectionCellDelegate: class {
    func didPushFavorite()
    func didPushSetting(video: Video, frame: CGRect)
    func didPushPlay(video: Video)
    func didPushChannel(video: Video)
}

class CardCollectionCell: UICollectionViewCell {
    var video: Video?
    var delegate: CardCollectionCellDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var channelButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBAction func didPushFavoriteButton(sender: AnyObject) {
        if let _v = self.video {
            if FavoriteManager.sharedInstance.isFavoriteVideo(_v.id) {
                self.favoriteButton.selected = false
                FavoriteManager.sharedInstance.removeFavoriteVideo(_v)
                changeLikeCount(false)
            }
            else {
                self.favoriteButton.selected = true
                FavoriteManager.sharedInstance.addFavoriteVideo(_v)
                NIFTYManager.sharedInstance.incrementLike(_v)
                changeLikeCount(true)
            }
            self.delegate?.didPushFavorite()
        }
    }
    @IBAction func didPushSettingButton(sender: AnyObject) {
        if let _v = self.video {
            self.delegate?.didPushSetting(_v, frame: self.frame)
        }
    }
    @IBAction func didPushPlayButton(sender: AnyObject) {
        if let _v = self.video {
            self.delegate?.didPushPlay(_v)
        }
    }
    @IBAction func didPushChannelButton(sender: AnyObject) {
        if let _v = self.video {
            self.delegate?.didPushChannel(_v)
        }
    }
    
    override func awakeFromNib() {
        self.settingButton.titleLabel?.minimumScaleFactor = 0.3
        self.settingButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func setup(video: Video, delegate: CardCollectionCellDelegate?) {
        self.delegate = delegate
        self.video = video
        self.channelButton.hidden = Config.isNotDevMode()
        setupFavoButton(video.id)
    }
    
    private func setupFavoButton(id: String) {
        self.favoriteButton.hidden  = !Config.isNotDevMode()
        self.likeLabel.hidden       = !Config.isNotDevMode()
        self.favoriteButton.selected = FavoriteManager.sharedInstance.isFavoriteVideo(id)
    }
    
    private func changeLikeCount(isAdd: Bool) {
        if let text = self.likeLabel.text {
            if var num = Int(text) {
                if isAdd {
                    num += 1
                }
                else {
                    num -= 1
                }
                self.video?.likeCount = num
            }
        }
    }
}