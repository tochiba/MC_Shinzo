//
//  ReviewRequestViewController.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/04/12.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit

protocol ReviewControllerDelegate: class {
    func didPushFeedBackButton()
}

class ReviewController: DialogViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var closeView: UIImageView!
    
    var delegate: ReviewControllerDelegate?
    var showCloseButton: Bool = true
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sendScreenNameLog()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeView.hidden = !self.showCloseButton
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didPushClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPushCancel(sender: AnyObject) {
        stepup(sender.tag)
    }
    
    @IBAction func didPushOK(sender: AnyObject) {
        stepup(sender.tag)
    }
    
    private func stepup(tag: Int) {
        switch tag {
        case 1:
            self.detailLabel.text = FeedBack.detailText
            self.cancelButton.setTitle(FeedBack.cancelText, forState: .Normal)
            self.cancelButton.tag = FeedBack.cancelTag
            self.okButton.setTitle(FeedBack.okText, forState: .Normal)
            self.okButton.tag = FeedBack.okTag
            break
        case 2:
            self.detailLabel.text = Review.detailText
            self.cancelButton.setTitle(Review.cancelText, forState: .Normal)
            self.cancelButton.tag = Review.cancelTag
            self.okButton.setTitle(Review.okText, forState: .Normal)
            self.okButton.tag = Review.okTag
            break
        case FeedBack.cancelTag:
            self.dismissViewControllerAnimated(true, completion: nil)
            break
        case FeedBack.okTag:
            ReviewChecker.setDisplayed()
            self.dismissViewControllerAnimated(true, completion: {
                self.delegate?.didPushFeedBackButton()
            })
            break
        case Review.cancelTag:
            self.dismissViewControllerAnimated(true, completion: nil)
            break
        case Review.okTag:
            let str = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1104660363"
            if let url = NSURL(string: str) {
                ReviewChecker.setDisplayed()
                UIApplication.sharedApplication().openURL(url)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            break
        default:
            break
        }
    }
}

struct FeedBack {
    static let detailText   = NSLocalizedString("review_detail", comment: "")
    static let cancelText   = NSLocalizedString("review_no1", comment: "")
    static let cancelTag    = 11
    static let okText       = NSLocalizedString("review_yes1", comment: "")
    static let okTag        = 12
}

struct Review {
    static let detailText   = NSLocalizedString("review_request", comment: "")
    static let cancelText   = NSLocalizedString("review_no2", comment: "")
    static let cancelTag    = 21
    static let okText       = NSLocalizedString("review_yes2", comment: "")
    static let okTag        = 22
}


class ReviewChecker: NSObject {
    class func favoriteCheck(viewController: UIViewController) -> Bool {
        let num = FavoriteCounter.getCount()
        if num > 3 {
            FavoriteCounter.reset()
            
            if isDisplayed() {
                Interstitial.sharedInstance.show(viewController)
                return false
            }
            
            if (arc4random() % 2) == 0 {
                return true
            }
            else {
                Interstitial.sharedInstance.show(viewController)
                return false
            }
            
        }
        
        return false
    }
    
    class func playCheck(viewController: UIViewController) -> Bool {
        let num = PlayCounter.getCount()
        if num > 4 {
            PlayCounter.reset()

            if isDisplayed() {
                Interstitial.sharedInstance.show(viewController)
                return false
            }

            if (arc4random() % 2) == 0 {
                return true
            }
            else {
                Interstitial.sharedInstance.show(viewController)
                return false
            }
        }
        
        return false
    }
    
    class func isDisplayed() -> Bool {
        if let currentVer = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            return NSUserDefaults.standardUserDefaults().boolForKey(currentVer)
        }
        return false
    }
    
    class func setDisplayed() {
        if let currentVer = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: currentVer)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

}

class PlayCounter: NSObject {
    static let PLAY_COUNT_KEY       = "PlayCountKey"
    static let PLAY_TOTAL_COUNT_KEY = "PlayTotalCountKey"
    
    class func add() {
        var i = getCount()
        i += 1
        NSUserDefaults.standardUserDefaults().setInteger(i, forKey: PLAY_COUNT_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        var t = getTotalCount()
        t += 1
        NSUserDefaults.standardUserDefaults().setInteger(t, forKey: PLAY_TOTAL_COUNT_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func reset() {
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: PLAY_COUNT_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getCount() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(PLAY_COUNT_KEY)
    }
    
    class func getTotalCount() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(PLAY_TOTAL_COUNT_KEY)
    }
}

class FavoriteCounter: NSObject {
    static let FAVORITE_COUNT_KEY       = "FavoriteCountKey"
    static let FAVORITE_TOTAL_COUNT_KEY = "FavoriteTotalCountKey"
    
    class func add() {
        var i = getCount()
        i += 1
        NSUserDefaults.standardUserDefaults().setInteger(i, forKey: FAVORITE_COUNT_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        var t = getTotalCount()
        t += 1
        NSUserDefaults.standardUserDefaults().setInteger(t, forKey: FAVORITE_TOTAL_COUNT_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func reset() {
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: FAVORITE_COUNT_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getCount() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(FAVORITE_COUNT_KEY)
    }
    
    class func getTotalCount() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(FAVORITE_TOTAL_COUNT_KEY)
    }
}