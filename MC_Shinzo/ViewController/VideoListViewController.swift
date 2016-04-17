//
//  VideoListViewController.swift
//  MC_Shinzo
//
//  Created by tochiba on 2016/03/31.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import WebImage
import XCDYouTubeKit
import SwiftRefresher
import Meyasubaco

class VideoListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var bannerView: BannerView!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    
    private var cellSize: CGSize = CGSizeZero
    private var videoList: [Video] = []
    private var isLoading: Bool = false
    private var pickerBaseView: PickerBaseView?
    
    var queryString: String = ""

    enum Mode {
        case Category
        case Favorite
        case New
        case Popular
        case Draft
    }
    var mode: Mode = .Category
    
    class func getInstance(query: String, color: UIColor=Config.baseColor()) -> VideoListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewControllerWithIdentifier("VideoListViewController") as? VideoListViewController {
            vc.queryString = query
            vc.view.backgroundColor = color
            vc.collectionView.backgroundColor = color
            return vc
        }
        
        return self.init()
    }
    
    class func getInstanceWithMode(mode: Mode, color: UIColor=Config.baseColor()) -> VideoListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewControllerWithIdentifier("VideoListViewController") as? VideoListViewController {
            vc.view.backgroundColor = color
            vc.collectionView.backgroundColor = color
            vc.mode = mode
            return vc
        }
        
        return self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicator.hidden = false
        self.indicator.startAnimating()
        self.bannerView.setup(self, unitID: AD.BannerUnitID)
        
        let refresher = Refresher { [weak self] () -> Void in
            self?.reload()
            self?.loadData()
            self?.collectionView.reloadData()
            self?.collectionView.srf_endRefreshing()
        }
        self.collectionView.srf_addRefresher(refresher)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupColloectionView()
    }
       
    override func viewDidLayoutSubviews() {
        setupCellSize()
        setupLayout()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        setData()
        
        if ReviewChecker.playCheck(self) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let nVC = storyboard.instantiateViewControllerWithIdentifier("ReviewController") as? ReviewController {
                nVC.delegate = self
                nVC.showCloseButton = false
                self.presentViewController(nVC, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func deviceOrientationDidChange(notification: NSNotification) {
        setupCellSize()
    }
}

extension VideoListViewController {
    private func setupLayout() {
        if self.mode == .Draft {
            setupSearchLayout()
        }
    }
    
    private func setData() {
        switch self.mode {
        case .Category:
            NIFTYManager.sharedInstance.search(self.queryString, aDelegate: self)
            return
        case .Favorite:
            FavoriteManager.sharedInstance.load(self)
            return
        case .New:
            NIFTYManager.sharedInstance.search(true, aDelegate: self)
            return
        case .Popular:
            NIFTYManager.sharedInstance.search(false, aDelegate: self)
            return
        case .Draft:
            APIManager.sharedInstance.search(self.queryString, aDelegate: self)
            return
        }
    }
    
    private func loadData() {
        switch self.mode {
        case .Category:
            self.videoList = NIFTYManager.sharedInstance.getVideos(self.queryString)
            return
        case .Favorite:
            self.videoList = FavoriteManager.sharedInstance.getFavoriteVideos()
            return
        case .New:
            self.videoList = NIFTYManager.sharedInstance.getVideos("New")
            return
        case .Popular:
            self.videoList = NIFTYManager.sharedInstance.getVideos("Popular")
            return
        case .Draft:
            self.videoList = APIManager.sharedInstance.getVideos(self.queryString)
            return
        }
    }
    
    private func setupColloectionView() {
        if let nvc = self.parentViewController as? UINavigationController {
            for vc in nvc.viewControllers {
                if let vlc = vc as? VideoListViewController {
                    vlc.collectionView.scrollsToTop = false
                }
            }
        }
        self.collectionView.scrollsToTop = true
    }
    
    private func setupCellSize() {
        let space: Int = 1 //マージン
        var spaceNum: Int = 0 //スペースの数
        var cellNum: Int = 1 //セルの数
        
        if UIApplication.isLandscape() {
            if UIApplication.isPad() {
                spaceNum = 2
                cellNum  = 3
            }
            else {
                spaceNum = 1
                cellNum  = 2
            }
        }
        else {
            if UIApplication.isPad() {
                spaceNum = 1
                cellNum  = 2
            }
            else {
                spaceNum = 0
                cellNum  = 1
            }
        }
        
        let screenSizeWidth = self.view.frame.size.width//UIScreen.mainScreen().bounds.size.width
        let size = (screenSizeWidth - CGFloat(space * spaceNum)) / CGFloat(cellNum)
        self.cellSize = CGSizeMake(size, size * 0.6)
        self.collectionView.reloadData()
    }
    
    private func reload() {
        if isLoading == true {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.isLoading = true
            dispatch_async(dispatch_get_main_queue(), {
                self.loadData()
                self.indicator.startAnimating()
                self.indicator.hidden = true
                self.collectionView.reloadData()
                self.isLoading = false
            })
        })
    }
    
    private func playVideo(id: String) {
        let vc = VideoViewController(videoIdentifier: id)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerPlaybackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: vc.moviePlayer)
        self.presentViewController(vc, animated: true, completion: nil)
//        self.presentMoviePlayerViewControllerAnimated(vc)
    }
    
    func moviePlayerPlaybackDidFinish(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

extension VideoListViewController: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videoList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VideoCell", forIndexPath: indexPath) as? CardCollectionCell {
            let video = self.videoList[indexPath.row]
            
            cell.imageView.image = nil
            if let url = NSURL(string: video.thumbnailUrl) {
                cell.imageView.sd_setImageWithURL(url)
            }
            cell.titleLabel.text = video.title
            cell.likeLabel.text = String(video.likeCount)
            cell.setup(video, delegate: self)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension VideoListViewController: UICollectionViewDelegate {
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
}

extension VideoListViewController: UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.cellSize
    }
}

extension VideoListViewController: SearchAPIManagerDelegate {
    func didFinishLoad() {
        reload()
    }
}

extension VideoListViewController: NIFTYManagerDelegate {
    func didLoad() {
        reload()
    }
}

extension VideoListViewController: FavoriteManagerDelegate {
    func didLoadFavoriteData() {
        reload()
    }
}

extension VideoListViewController: CardCollectionCellDelegate {
    func didPushFavorite() {
        reload()
        FavoriteCounter.add()
        if ReviewChecker.favoriteCheck(self) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let nVC = storyboard.instantiateViewControllerWithIdentifier("ReviewController") as? ReviewController {
                nVC.delegate = self
                nVC.showCloseButton = false
                self.presentViewController(nVC, animated: true, completion: nil)
            }
        }
    }
    
    func didPushSetting(video: Video, frame: CGRect) {
        
        let myAlert = UIAlertController(title: video.title, message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let myAction_1 = UIAlertAction(title: NSLocalizedString("share_share", comment: ""), style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            ActivityManager.showActivityView(self, video: video)
        })
        
        let myAction_2 = UIAlertAction(title: NSLocalizedString("share_illegal", comment: ""), style: UIAlertActionStyle.Destructive, handler: {
            (action: UIAlertAction) in
            NIFTYManager.sharedInstance.illegalThisVideo(video)
        })
        
        let myAction_3 = UIAlertAction(title: NSLocalizedString("share_cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
            (action: UIAlertAction) in
        })
        
        if !Config.isNotDevMode() {
            resetPickerView()
            let myAction_0 = UIAlertAction(title: NSLocalizedString("この動画を入稿する", comment: ""), style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction) in
                //NIFTYManager.sharedInstance.deliverThisVideo(video)
                self.createPickerView(video, frame: frame)
            })
            myAlert.addAction(myAction_0)
        }
        
        myAlert.addAction(myAction_1)
        myAlert.addAction(myAction_2)
        myAlert.addAction(myAction_3)
        
        if UIApplication.isPad() {
            myAlert.popoverPresentationController?.sourceView = self.collectionView
            myAlert.popoverPresentationController?.sourceRect = frame
        }
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func didPushPlay(video: Video) {
        playVideo(video.id)
        PlayCounter.add()
    }
}

extension VideoListViewController: ReviewControllerDelegate {
    func didPushFeedBackButton() {
        Meyasubaco.showCommentViewController(self)
    }
}

extension VideoListViewController: UISearchBarDelegate {
    private func setupSearchLayout() {
        self.topSpace.constant = -60
        
        if  self.navigationItem.titleView is UISearchBar {
            return
        }
        
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "Search"
            searchBar.showsCancelButton = false
            searchBar.tintColor = Config.keyColor()
            searchBar.autocapitalizationType = UITextAutocapitalizationType.None
            searchBar.keyboardType = UIKeyboardType.Default
            self.navigationItem.titleView = searchBar
            self.navigationItem.titleView?.frame = searchBar.frame
            let leftButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "didPushLeftButton:")
            leftButton.tintColor = Config.keyColor()
            self.navigationItem.leftBarButtonItem = leftButton
            
            searchBar.becomeFirstResponder()
        }
    }
    func didPushLeftButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // テキストが変更される毎に呼ばれる
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    }
    // Cancelボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
    }
    // Searchボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let txt = searchBar.text {
            self.queryString = txt
            APIManager.sharedInstance.search(self.queryString, aDelegate: self)
            self.view.endEditing(true)
        }
    }
}

extension VideoListViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    private func resetPickerView() {
        self.pickerBaseView?.removeFromSuperview()
        self.pickerBaseView = nil
    }
    private func createPickerView(video: Video, frame: CGRect) {
        var f = frame
        f.origin.y += 10
        f.size.height -= 10
        self.pickerBaseView = PickerBaseView(frame: f)
        self.pickerBaseView?.backgroundColor = UIColor.whiteColor()
        self.pickerBaseView?.video = video
        self.pickerBaseView?.category = VideoCategory.category[0]
        
        var pf = f
        pf.size.height -= 40
        pf.origin.x = 0
        pf.origin.y = 0
        let pview = UIPickerView()
        pview.frame = pf
        pview.delegate = self
        pview.dataSource = self
        
        var bf = pf
        bf.size.height = 40
        bf.origin.y = pf.size.height
        let button = UIButton()
        button.frame = bf
        button.setTitle("決定", forState: UIControlState.Normal)
        button.backgroundColor = Config.keyColor(0.3)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        button.titleLabel?.text = "決定"
        button.addTarget(self, action: "didPushDeliverButton:", forControlEvents: .TouchUpInside)
        
        self.pickerBaseView?.addSubview(button)
        self.pickerBaseView?.addSubview(pview)
        if let view = self.pickerBaseView {
            self.collectionView?.addSubview(view)
        }
    }
    func didPushDeliverButton(sender: UIButton) {
        if let p = sender.superview as? PickerBaseView {
            if let v = p.video {
                let _v = v
                _v.categoryName = p.category
                NIFTYManager.sharedInstance.deliverThisVideo(_v)
                resetPickerView()
            }
        }
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return VideoCategory.category.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return VideoCategory.category[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let p = pickerView.superview as? PickerBaseView {
            p.category = VideoCategory.category[row]
        }
    }
}

class PickerBaseView: UIView {
    var video: Video?
    var category: String = "None"
}