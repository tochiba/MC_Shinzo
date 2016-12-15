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
import ARSLineProgress

class VideoListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bannerView: BannerView!
    @IBOutlet weak var topSpace: NSLayoutConstraint!

    
    internal var cellSize: CGSize = .zero
    internal var videoList: [Video] = []
    internal var pickerBaseView: PickerBaseView?
    internal var scrollBeginingPoint: CGPoint = CGPoint(x:0, y:0)
    
    var titleString: String = ""
    var queryString: String = ""

    enum Mode {
        case Category
        case Favorite
        case New
        case Popular
        case Draft
        case Channel
        case Search
        case Rapper
    }
    var mode: Mode = .New
    
    class func getInstance(query: String, color: UIColor=Config.baseColor()) -> VideoListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "VideoListViewController") as? VideoListViewController {
            vc.queryString = query
            vc.view.backgroundColor = color
            vc.collectionView.backgroundColor = color
            return vc
        }
        
        return self.init()
    }
    
    class func getInstanceWithMode(query: String = "", title: String = "", mode: Mode, color: UIColor=Config.baseColor()) -> VideoListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "VideoListViewController") as? VideoListViewController {
            vc.view.backgroundColor = color
            vc.collectionView.backgroundColor = color
            vc.mode = mode
            vc.titleString = title
            if mode != .Draft {
                vc.queryString = query
            }
            vc.setData()
            return vc
        }
        
        return self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        self.bannerView.setup(self, unitID: AD.BannerUnitID)
        
        let refresher = Refresher { [weak self] () -> Void in
            self?.pullToRefresh()
            TrackingManager.sharedInstance.sendEventAction(.refresh)
        }
        self.collectionView.srf_addRefresher(refresher)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColloectionView()
        self.sendScreenNameLog()
        TrackingManager.sharedInstance.sendEventCategory(self.queryString)
    }
       
    override func viewDidLayoutSubviews() {
        setupCellSize()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoListViewController.deviceOrientationDidChange(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        // 3D Touchが使える端末か確認
        if UIApplication.shared.keyWindow?.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            // どのビューをPeek and Popの対象にするか指定
            self.registerForPreviewing(with: self, sourceView: self.view)
        }
        if ReviewChecker.playCheck(self) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let nVC = storyboard.instantiateViewController(withIdentifier: "ReviewController") as? ReviewController {
                nVC.delegate = self
                nVC.showCloseButton = false
                self.present(nVC, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        ARSLineProgressConfiguration.backgroundViewDismissAnimationDuration = 1.0
        ARSLineProgress.hideWithCompletionBlock({
            ARSLineProgressConfiguration.restoreDefaults()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func deviceOrientationDidChange(notification: NSNotification) {
        setupCellSize()
    }
}

extension VideoListViewController {
    func setupLayout() {
        if self.mode == .Draft || self.mode == .Search {
            setupSearchLayout()
        }
        if self.mode == .Channel {
            setupChannelLayout()
        }
    }
    
    func setData() {
        ARSLineProgress.show()
        
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
            APIManager.sharedInstance.search(self.queryString, aDelegate: self, mode: .channel)
            return
        case .Search:
            NIFTYManager.sharedInstance.searchFromContents(self.queryString, aDelegate: self)
        case .Rapper:
            NIFTYManager.sharedInstance.searchFromContents(self.queryString, aDelegate: self)
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
        case .Search:
            self.videoList = NIFTYManager.sharedInstance.getVideos(self.queryString)
            return
        case .Rapper:
            self.videoList = NIFTYManager.sharedInstance.getVideos(self.queryString)
            return
        }
    }
    
    internal func setupColloectionView() {
        if let nvc = self.parent as? UINavigationController {
            for vc in nvc.viewControllers {
                if let vlc = vc as? VideoListViewController {
                    vlc.collectionView.scrollsToTop = false
                }
            }
        }
        self.collectionView.scrollsToTop = true
    }
    
    // TODO: Cell間のマージンが大きすぎる（2つ分のマージンになってるから？cellのレイアウトだから厳しいかも）
    internal func setupCellSize(num: Int = 0, heightRaito: CGFloat = 0.6) {
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
        self.cellSize = CGSize(width: size, height: size * heightRaito)
        self.collectionView.reloadData()
    }
    
    internal func reload(isScrollToTop: Bool = true, showSuccess: Bool = false) {
        self.loadData()
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
            }, completion: { finish in
                if showSuccess {
                    ARSLineProgress.showSuccess()
                }
                else {
                    ARSLineProgressConfiguration.backgroundViewDismissAnimationDuration = 1.0
                    ARSLineProgress.hideWithCompletionBlock({
                        ARSLineProgressConfiguration.restoreDefaults()
                    })
                }
                
                if isScrollToTop && self.videoList.count > 0 {
                    self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: true)
                }
        })
    }
    
    internal func pullToRefresh() {
        setData()
        DispatchQueue.main.async() { [weak self] () -> Void in
            guard let s = self else { return }
            s.collectionView.srf_endRefreshing()
        }
    }
    
    internal func playVideo(id: String) {
        let vc = VideoViewController(videoIdentifier: id)
        self.present(vc, animated: true, completion: nil)
    }
    
    func moviePlayerPlaybackDidFinish(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension VideoListViewController: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videoList.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as? CardCollectionCell {
            let video = self.videoList[indexPath.row]
            
            cell.imageView.image = nil
            if let url = Foundation.URL(string: video.thumbnailUrl) {
                cell.imageView.sd_setImage(with: url)
            }
            cell.titleLabel.text = video.title
            cell.likeLabel.text = String(video.likeCount)
            cell.channelButton.setTitle(video.channelName, for: .normal)
            cell.setup(video, delegate: self)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension VideoListViewController: UICollectionViewDelegate {
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}

extension VideoListViewController: UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        /*
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
         */
        return self.cellSize
    }
}

extension VideoListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        // 3D Touchの対象がUITableViewかどうかを判別（UITableViewでの位置を取得）
        let cellPosition: CGPoint = self.collectionView.convert(location, from: view)        
        // 3D Touchされた場所が存在するかどうか判定
        // Peekを表示させたくない、表示すべきではない場合は"nil"を返す
        guard let indexPath: NSIndexPath = self.collectionView.indexPathForItem(at: cellPosition) as NSIndexPath? else {
            return nil
        }
        
        // Peekで表示させる画面のインスタンス生成
        guard let cell = self.collectionView.cellForItem(at: indexPath as IndexPath) as? CardCollectionCell else {
            return nil
        }

        let vc = VideoViewController(videoIdentifier: cell.video?.id)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoListViewController.moviePlayerPlaybackDidFinish(_:)), name: MPMoviePlayerPlaybackDidFinishNotification, object: vc.moviePlayer)
        
        // Peekで表示させるプレビュー画面の大きさを指定
        // 基本的にwidthの数値は無視される
        vc.preferredContentSize = CGSize(width: 0.0, height: UIScreen.main.bounds.size.height * 0.7)
        
        // 3D Touchではっきりと表示させる部分を指定（どの部分をぼかして、どの部分をPeekしているかを設定）
        previewingContext.sourceRect = view.convert(cell.frame, from: self.collectionView)

        // 次の画面のインスタンスを返す
        return vc
    }
    
    // Popする直前に呼ばれる処理（通常は次の画面を表示させる）
    // UINavigationControllerでのpushでの遷移は"showViewController:sender:"をコールする
    // Modalでの遷移の場合は"presentViewController:animated:completion:"をコールする
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
        //showViewController(viewControllerToCommit, sender: self)
    }
}

extension VideoListViewController: SearchAPIManagerDelegate {
    func didFinishLoad(_ videos: [Video]) {
        DispatchQueue.main.async(execute: {
            self.reload(isScrollToTop: false)
        })
    }
}

extension VideoListViewController: NIFTYManagerDelegate {
    func didLoad() {
        DispatchQueue.main.async(execute: {
            self.reload()
        })
    }
}

extension VideoListViewController: FavoriteManagerDelegate {
    func didLoadFavoriteData() {
        DispatchQueue.main.async(execute: {
            self.reload()
        })
    }
}

extension VideoListViewController: CardCollectionCellDelegate {
    func didPushFavorite() {
        reload(isScrollToTop: false ,showSuccess: true)
        FavoriteCounter.add()
        if ReviewChecker.favoriteCheck(self) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let nVC = storyboard.instantiateViewController(withIdentifier: "ReviewController") as? ReviewController {
                nVC.delegate = self
                nVC.showCloseButton = false
                self.present(nVC, animated: true, completion: nil)
            }
        }
        TrackingManager.sharedInstance.sendEventAction(.favorite)
    }
    
    func didPushSetting(_ video: Video, frame: CGRect) {
        
        let myAlert = UIAlertController(title: video.title, message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        let myAction_1 = UIAlertAction(title: NSLocalizedString("share_share", comment: ""), style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction) in
            ActivityManager.showActivityView(self, video: video)
        })
        
        let myAction_2 = UIAlertAction(title: NSLocalizedString("share_illegal", comment: ""), style: UIAlertActionStyle.destructive, handler: {
            (action: UIAlertAction) in
            NIFTYManager.sharedInstance.illegalThisVideo(video)
        })
        
        let myAction_3 = UIAlertAction(title: NSLocalizedString("share_cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction) in
        })
        
        if !Config.isNotDevMode() {
            resetPickerView()
            let myAction_01 = UIAlertAction(title: NSLocalizedString("この動画を削除する", comment: ""), style: UIAlertActionStyle.destructive, handler: {
                (action: UIAlertAction) in
                NIFTYManager.sharedInstance.deleteThisVideo(video)
            })
            myAlert.addAction(myAction_01)
            
            let myAction_00 = UIAlertAction(title: NSLocalizedString("この動画を入稿する", comment: ""), style: UIAlertActionStyle.default, handler: {
                (action: UIAlertAction) in
                self.createPickerView(video: video, frame: frame)
            })
            myAlert.addAction(myAction_00)
            
            
            if !NIFTYManager.sharedInstance.isDeliveredChannel(video) {
                let myAction_03 = UIAlertAction(title: NSLocalizedString("このチャンネルを登録する", comment: ""), style: UIAlertActionStyle.default, handler: {
                    (action: UIAlertAction) in
                    NIFTYManager.sharedInstance.deliverThisChannel(video)
                })
                myAlert.addAction(myAction_03)
            }
            
            let myAction_04 = UIAlertAction(title: NSLocalizedString("この動画をPUSH配信する", comment: ""), style: UIAlertActionStyle.default, handler: {
                (action: UIAlertAction) in
                APIManager.sharedInstance.postNotification(video)
            })
            myAlert.addAction(myAction_04)

        }
        
        myAlert.addAction(myAction_1)
        myAlert.addAction(myAction_2)
        myAlert.addAction(myAction_3)
        
        if UIApplication.isPad() {
            myAlert.popoverPresentationController?.sourceView = self.collectionView
            myAlert.popoverPresentationController?.sourceRect = frame
        }
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func didPushPlay(_ video: Video) {
        playVideo(id: video.id)
        PlayCounter.add()
        TrackingManager.sharedInstance.sendEventAction(.play)
    }
    
    func didPushChannel(_ video: Video) {
        let vc = VideoListViewController.getInstanceWithMode(query: video.channelId, title: video.channelName, mode: .Channel)
        let nvc = AnimationNavigationController(rootViewController: vc)
        self.present(nvc, animated: true, completion: nil)
    }
}

extension VideoListViewController: ReviewControllerDelegate {
    func didPushFeedBackButton() {
        Meyasubaco.showCommentViewController(self)
    }
}

extension VideoListViewController: UISearchBarDelegate {
    internal func setupSearchLayout() {
        self.topSpace.constant = 0
        
        if  self.navigationItem.titleView is UISearchBar {
            return
        }
        
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "Search"
            searchBar.showsCancelButton = false
            searchBar.tintColor = UIColor.darkGray
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            searchBar.keyboardType = UIKeyboardType.default
            self.navigationItem.titleView = searchBar
            self.navigationItem.titleView?.frame = searchBar.frame
            let leftButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(VideoListViewController.didPushLeftButton(sender:)))
            leftButton.tintColor = UIColor.white
            self.navigationItem.leftBarButtonItem = leftButton
            
            searchBar.becomeFirstResponder()
        }
    }
    func didPushLeftButton(sender: UIButton) {
        if self.mode == .Search {
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    // テキストが変更される毎に呼ばれる
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }
    // Cancelボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    // Searchボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let txt = searchBar.text {
            ARSLineProgress.show()
            self.queryString = txt
            self.view.endEditing(true)
            searchBar.resignFirstResponder()
            self.videoList = []
            if self.mode == .Draft {
                APIManager.sharedInstance.search(self.queryString, aDelegate: self)
            }
            else if self.mode == .Search {
                NIFTYManager.sharedInstance.searchFromContents(self.queryString, aDelegate: self)
            }
        }
    }
}

extension VideoListViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    internal func resetPickerView() {
        self.pickerBaseView?.removeFromSuperview()
        self.pickerBaseView = nil
    }
    internal func createPickerView(video: Video, frame: CGRect) {
        var f = frame
        f.origin.y += 10
        f.size.height -= 10
        self.pickerBaseView = PickerBaseView(frame: f)
        self.pickerBaseView?.backgroundColor = UIColor.white
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
        button.setTitle("決定", for: UIControlState.normal)
        button.backgroundColor = Config.keyColor(0.3)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        button.titleLabel?.text = "決定"
        button.addTarget(self, action: #selector(VideoListViewController.didPushDeliverButton(sender:)), for: .touchUpInside)
        
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
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return VideoCategory.category.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return VideoCategory.category[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let p = pickerView.superview as? PickerBaseView {
            p.category = VideoCategory.category[row]
        }
    }
}

extension VideoListViewController {
    internal func setupChannelLayout() {
        self.topSpace.constant = 0
        
        if  self.navigationItem.titleView is UISearchBar {
            return
        }
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let titleView = UILabel(frame: navigationBarFrame)
            titleView.text = self.titleString
            titleView.textAlignment = .center
            self.navigationItem.titleView = titleView
            self.navigationItem.titleView?.frame = titleView.frame
        }
        let leftButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(VideoListViewController.didPushCloseButton(sender:)))
        self.navigationItem.leftBarButtonItem = leftButton
    }
    func didPushCloseButton(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

class PickerBaseView: UIView {
    var video: Video?
    var category: String = "None"
}

extension VideoListViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollBeginingPoint = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset
        UIApplication.shared.isStatusBarHidden = scrollBeginingPoint.y < currentPoint.y
    }
}

