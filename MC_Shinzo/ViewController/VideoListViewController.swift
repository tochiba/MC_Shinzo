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
    private var pickerBaseView: PickerBaseView?
    
    var titleString: String = ""
    var queryString: String = ""

    enum Mode {
        case Category
        case Favorite
        case New
        case Popular
        case Draft
        case Channel
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
    
    class func getInstanceWithMode(query: String = "", title: String = "", mode: Mode, color: UIColor=Config.baseColor()) -> VideoListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewControllerWithIdentifier("VideoListViewController") as? VideoListViewController {
            vc.view.backgroundColor = color
            vc.collectionView.backgroundColor = color
            vc.mode = mode
            vc.titleString = title
            if mode != .Draft {
                vc.queryString = query
            }
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
            TrackingManager.sharedInstance.sendEventAction(.Refresh)
        }
        self.collectionView.srf_addRefresher(refresher)
        
        // 3D Touchが使える端末か確認
        if UIApplication.sharedApplication().keyWindow?.traitCollection.forceTouchCapability == UIForceTouchCapability.Available {
            // どのビューをPeek and Popの対象にするか指定
            self.registerForPreviewingWithDelegate(self, sourceView: self.view)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupColloectionView()
        self.sendScreenNameLog()
        TrackingManager.sharedInstance.sendEventCategory(self.queryString)
    }
       
    override func viewDidLayoutSubviews() {
        setupCellSize()
        setupLayout()
        setData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoListViewController.deviceOrientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
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
        if self.mode == .Channel {
            setupChannelLayout()
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
        case .Channel:
            APIManager.sharedInstance.search(self.queryString, aDelegate: self, mode: .Channel)
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
        case .Channel:
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
    
    // TODO: Cell間のマージンが大きすぎる（2つ分のマージンになってるから？cellのレイアウトだから厳しいかも）
    private func setupCellSize(num: Int = 0, heightRaito: CGFloat = 0.6) {
        let space: Int = 2 //マージン
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
        spaceNum += num
        cellNum  += num
        let screenSizeWidth = self.view.frame.size.width//UIScreen.mainScreen().bounds.size.width
        let size = (screenSizeWidth - CGFloat(space * spaceNum)) / CGFloat(cellNum)
        self.cellSize = CGSizeMake(size, size * heightRaito)
        self.collectionView.reloadData()
    }
    
    private func reload() {
        self.loadData()
        self.indicator.stopAnimating()
        self.indicator.hidden = true
        self.collectionView.reloadData()
    }
    
    private func playVideo(id: String) {
        let vc = VideoViewController(videoIdentifier: id)
        self.presentViewController(vc, animated: true, completion: nil)
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
            cell.channelButton.setTitle(video.channelName, forState: .Normal)
            cell.setup(video, delegate: self)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension VideoListViewController: UICollectionViewDelegate {
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {}
}

extension VideoListViewController: UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if !(self.mode == .New || self.mode == .Popular) {
            return self.cellSize
        }
        
        if UIApplication.isLandscape() {
            if UIApplication.isPad() {
                if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 {
                    setupCellSize(heightRaito: 0.5)
                }
                else {
                    setupCellSize(1)
                }
            }
            else {
                if indexPath.row == 0 || indexPath.row == 1 {
                    setupCellSize(heightRaito: 0.5)
                }
                else {
                    setupCellSize(1)
                }
            }
        }
        else {
            if UIApplication.isPad() {
                if indexPath.row == 0 || indexPath.row == 1 {
                    setupCellSize(heightRaito: 0.5)
                }
                else {
                    setupCellSize(1)
                }
            }
            else {
                if indexPath.row == 0 {
                    setupCellSize(heightRaito: 0.5)
                }
                else {
                    setupCellSize(1)
                }
            }
        }
        return self.cellSize
    }
}

extension VideoListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        // 3D Touchの対象がUITableViewかどうかを判別（UITableViewでの位置を取得）
        guard let cellPosition: CGPoint = self.collectionView.convertPoint(location, fromView: view) else {
            return nil
        }
        
        // 3D Touchされた場所が存在するかどうか判定
        // Peekを表示させたくない、表示すべきではない場合は"nil"を返す
        guard let indexPath: NSIndexPath = self.collectionView.indexPathForItemAtPoint(cellPosition) else {
            return nil
        }
        
        // Peekで表示させる画面のインスタンス生成
        guard let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? CardCollectionCell else {
            return nil
        }

        let vc = VideoViewController(videoIdentifier: cell.video?.id)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoListViewController.moviePlayerPlaybackDidFinish(_:)), name: MPMoviePlayerPlaybackDidFinishNotification, object: vc.moviePlayer)
        
        // Peekで表示させるプレビュー画面の大きさを指定
        // 基本的にwidthの数値は無視される
        vc.preferredContentSize = CGSize(width: 0.0, height: UIScreen.mainScreen().bounds.size.height * 0.7)
        
        // 3D Touchではっきりと表示させる部分を指定（どの部分をぼかして、どの部分をPeekしているかを設定）
        previewingContext.sourceRect = view.convertRect(cell.frame, fromView: self.collectionView)

        // 次の画面のインスタンスを返す
        return vc
    }
    
    // Popする直前に呼ばれる処理（通常は次の画面を表示させる）
    // UINavigationControllerでのpushでの遷移は"showViewController:sender:"をコールする
    // Modalでの遷移の場合は"presentViewController:animated:completion:"をコールする
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        presentViewController(viewControllerToCommit, animated: true, completion: nil)
        //showViewController(viewControllerToCommit, sender: self)
    }
}

extension VideoListViewController: SearchAPIManagerDelegate {
    func didFinishLoad() {
        reload()
    }
}

extension VideoListViewController: NIFTYManagerDelegate {
    func didLoad() {
        dispatch_async(dispatch_get_main_queue(), {
            self.reload()
        })
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
        TrackingManager.sharedInstance.sendEventAction(.Favorite)
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
                self.createPickerView(video, frame: frame)
            })
            myAlert.addAction(myAction_0)
            
            let myAction_1 = UIAlertAction(title: NSLocalizedString("この動画を削除する", comment: ""), style: UIAlertActionStyle.Destructive, handler: {
                (action: UIAlertAction) in
                NIFTYManager.sharedInstance.deleteThisVideo(video)
            })
            myAlert.addAction(myAction_1)
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
        TrackingManager.sharedInstance.sendEventAction(.Play)
    }
    
    func didPushChannel(video: Video) {
        let vc = VideoListViewController.getInstanceWithMode(video.channelId, title: video.channelName, mode: .Channel)
        let nvc = UINavigationController(rootViewController: vc)
        self.presentViewController(nvc, animated: true, completion: nil)
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
            let leftButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(VideoListViewController.didPushLeftButton(_:)))
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
        button.addTarget(self, action: #selector(VideoListViewController.didPushDeliverButton(_:)), forControlEvents: .TouchUpInside)
        
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

extension VideoListViewController {
    private func setupChannelLayout() {
        self.topSpace.constant = -60
        
        if  self.navigationItem.titleView is UISearchBar {
            return
        }
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let titleView = UILabel(frame: navigationBarFrame)
            titleView.text = self.titleString
            titleView.textAlignment = .Center
            self.navigationItem.titleView = titleView
            self.navigationItem.titleView?.frame = titleView.frame
        }
        let leftButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(VideoListViewController.didPushCloseButton(_:)))
        //leftButton.tintColor = Config.keyColor()
        self.navigationItem.leftBarButtonItem = leftButton
    }
    func didPushCloseButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class PickerBaseView: UIView {
    var video: Video?
    var category: String = "None"
}