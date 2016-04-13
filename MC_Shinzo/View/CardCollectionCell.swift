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
}

class CardCollectionCell: UICollectionViewCell {
    var video: Video?
    var delegate: CardCollectionCellDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBAction func didPushFavoriteButton(sender: AnyObject) {
        if let _v = self.video {
            if FavoriteManager.sharedInstance.isFavoriteVideo(_v.id) {
                self.favoriteButton.tintColor = UIColor.lightGrayColor()
                FavoriteManager.sharedInstance.removeFavoriteVideo(_v)
                changeLikeCount(false)
            }
            else {
                self.favoriteButton.tintColor = selectColor()
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
    
    override func awakeFromNib() {
        self.favoriteButton.setImage(getButtonImage(), forState: .Normal)
    }
    func setup(video: Video, delegate: CardCollectionCellDelegate?) {
        self.delegate = delegate
        self.video = video
        setupFavoButton(video.id)
    }
    
    private func setupFavoButton(id: String) {
        self.favoriteButton.hidden  = !Config.isNotDevMode()
        self.likeLabel.hidden       = !Config.isNotDevMode()
        
        if FavoriteManager.sharedInstance.isFavoriteVideo(id) {
            self.favoriteButton.tintColor = selectColor()
        }
        else {
            self.favoriteButton.tintColor = UIColor.lightGrayColor()
        }
    }
 
    private func getButtonImage() -> UIImage? {
        let image = UIImage(named: "favorite_tab")
        let _image = image?.imageWithRenderingMode(.AlwaysTemplate)
        return _image
    }
    
    private func selectColor() -> UIColor {
        return UIColor(red: 225/255, green: 125/255, blue: 205/255, alpha: 0.7)
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