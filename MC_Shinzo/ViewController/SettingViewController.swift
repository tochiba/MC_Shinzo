//
//  SettingViewController.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/04/02.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit
import Meyasubaco
import SafariServices
import ARSLineProgress

class SettingViewController: UIViewController {
    @IBOutlet weak var tableView: SettingTableView!
    @IBOutlet weak var bannerView: BannerView!
    var delegate: BaseControllerDelegate?
}
extension SettingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let sectionHeaderHeight = self.tableView.sectionHeaderHeight + 20
        let offSetY = scrollView.contentOffset.y
        if offSetY <= sectionHeaderHeight && offSetY >= 0 {
            scrollView.contentInset = UIEdgeInsetsMake(-offSetY, 0, 0, 0)
        }
        else if offSetY >= sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0)
        }
    }
}

class SettingTableView: UITableView {
    var timer: NSTimer = NSTimer()
    var counter: Int = 0
    weak var viewController: UIViewController?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if self.timer.valid {
            self.counter += 1
        }
        else {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(SettingTableView.resetTimer), userInfo: nil, repeats: false)
        }
        check()
    }
    
    func resetTimer() {
        self.counter = 0
        self.timer.invalidate()
    }
    
    private func check() {
        if self.counter > 11 {
            
            let alert: UIAlertController = UIAlertController(title:"Dev Mode",
                                                            message: "Input Password",
                                                            preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
                                                           style: UIAlertActionStyle.Cancel,
                                                           handler:{
                                                            (action:UIAlertAction!) -> Void in
            })
            let defaultAction:UIAlertAction = UIAlertAction(title: "OK",
                                                            style: UIAlertActionStyle.Default,
                                                            handler:{
                                                                (action:UIAlertAction!) -> Void in
                                                                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                                                                if textFields != nil {
                                                                    for textField:UITextField in textFields! {
                                                                        if textField.text == PASS.DevMode {
                                                                            Config.setDevMode(Config.isNotDevMode())
                                                                            self.reloadData()
                                                                            self.resetTimer()
                                                                        }
                                                                    }
                                                                }
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
                text.placeholder = "password"
                let label:UILabel = UILabel(frame: CGRectMake(0, 0, 50, 30))
                label.text = "PASS"
                text.leftView = label
                text.leftViewMode = UITextFieldViewMode.Always
                
            })
            self.viewController?.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension SettingViewController {
    class func getInstance() -> SettingViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewControllerWithIdentifier("SettingViewController") as? SettingViewController {
            vc.view.backgroundColor = Config.baseColor()
            vc.tableView.backgroundColor = Config.baseColor()
            return vc
        }
        
        return self.init()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.bannerView.setup(self, unitID: AD.DrawerBannerUnitID)
        self.tableView.viewController = self
        self.sendScreenNameLog()
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let sdata = SettingDataSection(rawValue: indexPath.section)
        
        if sdata == .Menu {
            if let mode = SettingDataMenuRow(rawValue: indexPath.row)?.contentsMode {
                self.delegate?.didSelectCell(mode, query: "")
            }
            
            return
        }
        
        if sdata == .Rapper {
            guard let rdata = SettingDataRapperRow(rawValue: indexPath.row) else {
                return
            }
            if let mode = rdata.contentsMode {
                self.delegate?.didSelectCell(mode, query: rdata.query)
            }
            
            return
        }
        
        if sdata == .Setting {
            let data = SettingDataSettingRow(rawValue: indexPath.row)
            if let segue = data?.segueID {
                if data != .DevChannel {
                    self.performSegueWithIdentifier(segue, sender: nil)
                }
                else if !Config.isNotDevMode() {
                    self.performSegueWithIdentifier(segue, sender: nil)
                }
            }
            else if data == .Request {
                Meyasubaco.showCommentViewController(self)
            }
            else if data == .Deliverd {
                let url = NSURL(string: URL.Twitter)!
                let brow = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
                brow.delegate = self
                presentViewController(brow, animated: true, completion: nil)
            }
            else if data == .DevMode {
                if !Config.isNotDevMode() {
                    let vc = VideoListViewController.getInstanceWithMode(mode: .Draft)
                    let nvc = UINavigationController(rootViewController: vc)
                    self.presentViewController(nvc, animated: true, completion: nil)
                }
            }
            else if data == .DevAutoDeliver {
                if !Config.isNotDevMode() {
                    ARSLineProgress.show()
                    TwitterManager.sharedInstance.startAutoFavorite()
                    AutoDeliverManager.sharedInstance.start()
                }
            }
            return
        }
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRectMake(0,0,tableView.frame.size.width,50))
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Left
        label.font = UIFont.systemFontOfSize(14)
        label.backgroundColor = UIColor.clearColor()
        label.text = SettingDataSection(rawValue: section)?.title
        return label
    }
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingDataSection(rawValue: section)?.title
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingDataSection(rawValue: section)?.heightOfSections ?? 0
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return SettingDataSection.NumberOfSections.numberOfSections
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingDataSection(rawValue: section)!.numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sdata = SettingDataSection(rawValue: indexPath.section)! as SettingDataSection
        let cell = tableView.dequeueReusableCellWithIdentifier(SettingDataSection.cellName, forIndexPath: indexPath)
        var text: String? = ""
        switch sdata {
        case .Menu:
            text = SettingDataMenuRow(rawValue: indexPath.row)?.title
            break
        case .Rapper:
            text = SettingDataRapperRow(rawValue: indexPath.row)?.title
            break
        case .Setting:
            text = SettingDataSettingRow(rawValue: indexPath.row)?.title
            break
        default:
            break
        }
        cell.textLabel?.text = text
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
}

extension SettingViewController: SFSafariViewControllerDelegate {
}

private enum SettingDataSection: Int {
    case Menu
    case Rapper
    case Setting
    case NumberOfSections
    
    static let cellName = "SettingCell"

    var numberOfSections: Int {
        return NumberOfSections.rawValue
    }
    
    var heightOfSections: CGFloat {
        return 50 //self == .Setting ? 30 : 0
    }
    
    var numberOfRows: Int {
        switch self {
        case .Menu:
            return SettingDataRow.Favorite.rawValue + 1
        case .Rapper:
            return SettingDataRapperRow.Dotama.numberOfRows
        case .Setting:
            if Config.isNotDevMode() {
                return SettingDataRow.Deliverd.rawValue - SettingDataRow.Favorite.rawValue
            }
            else {
                return SettingDataRow.DevAutoDeliver.rawValue - SettingDataRow.Favorite.rawValue
            }
        default:
            return 0
        }
    }
    
    var title: String {
        switch self {
        case .Menu:
            return "    " + NSLocalizedString("setting_menu", comment: "")
        case .Rapper:
            return "    " + NSLocalizedString("setting_rapper", comment: "")
        case .Setting:
            return "    " + NSLocalizedString("category_setting", comment: "")
        default:
            return ""
        }
    }
    
    private enum SettingDataRow: Int {
        case New
        case Popular
        case Favorite
        
        case Request
        case Copyright
        case Deliverd
        
        case DevMode
        case DevChannel
        case DevAutoDeliver
        case NumberOfRows
        

        var numberOfRows: Int {
            if Config.isNotDevMode() {
                return NumberOfRows.rawValue-1
            }
            else {
                return NumberOfRows.rawValue
            }
        }
        
        var title: String {
            switch self {
            case New:
                return NSLocalizedString("category_new", comment: "")
            case Popular:
                return NSLocalizedString("category_popular", comment: "")
            case Favorite:
                return NSLocalizedString("category_favorite", comment: "")
            case .Request:
                return NSLocalizedString("setting_request", comment: "")
            case .Copyright:
                return NSLocalizedString("setting_licence", comment: "")
            case .Deliverd:
                return NSLocalizedString("setting_deliverd", comment: "")
            case .DevMode:
                if Config.isNotDevMode() {
                    return ""
                }
                else {
                    return NSLocalizedString("setting_toolmode", comment: "")
                }
            case DevChannel:
                if Config.isNotDevMode() {
                    return ""
                }
                else {
                    return NSLocalizedString("登録チャンネル", comment: "")
                }
            case DevAutoDeliver:
                if Config.isNotDevMode() {
                    return ""
                }
                else {
                    return NSLocalizedString("自動入稿", comment: "")
                }
            case .NumberOfRows:
                return ""
            }
        }
        
        var segueID: String? {
            switch self {
            case New:
                return nil
            case Popular:
                return nil
            case Favorite:
                return nil
            case .Request:
                return nil
            case .Copyright:
                return "SettingToLicence"
            case .Deliverd:
                return nil
            case .DevMode:
                return nil
            case DevChannel:
                return "SettingToChannel"
            case DevAutoDeliver:
                return nil
            case .NumberOfRows:
                return nil
            }
        }
        
        var contentsMode: VideoListViewController.Mode? {
            switch self {
            case New:
                return VideoListViewController.Mode.New
            case Popular:
                return VideoListViewController.Mode.Popular
            case Favorite:
                return VideoListViewController.Mode.Favorite
            default:
                return nil
            }
        }
    }
}

private enum SettingDataMenuRow: Int {
    case New
    case Popular
    case Favorite
    case NumberOfRows
    
    var numberOfRows: Int {
        return NumberOfRows.rawValue
    }
    var title: String {
        switch self {
        case New:
            return NSLocalizedString("category_new", comment: "")
        case Popular:
            return NSLocalizedString("category_popular", comment: "")
        case Favorite:
            return NSLocalizedString("category_favorite", comment: "")
        default:
            return ""
        }
    }
    
    var segueID: String? {
        switch self {
        case New:
            return nil
        case Popular:
            return nil
        case Favorite:
            return nil
        default:
            return nil
        }
    }
    
    var contentsMode: VideoListViewController.Mode? {
        switch self {
        case New:
            return VideoListViewController.Mode.New
        case Popular:
            return VideoListViewController.Mode.Popular
        case Favorite:
            return VideoListViewController.Mode.Favorite
        default:
            return nil
        }
    }
}

private enum SettingDataRapperRow: Int {
    case Saue
    case Kan
    case Tpablow
    case Rshitei
    case Chico
    case Dotama
    case Ace
    case Takumaki
    case Mrq
    case NumberOfRows
    
    var numberOfRows: Int {
        return NumberOfRows.rawValue
    }
    var title: String {
        switch self {
        case Saue:
            return NSLocalizedString("サイプレス上野", comment: "")
        case Kan:
            return NSLocalizedString("漢 a.k.a GAMI", comment: "")
        case Tpablow:
            return NSLocalizedString("T-PABLOW", comment: "")
        case Rshitei:
            return NSLocalizedString("R-指定", comment: "")
        case Chico:
            return NSLocalizedString("CHICO CARLITO", comment: "")
        case Dotama:
            return NSLocalizedString("DOTAMA", comment: "")
        case Ace:
            return NSLocalizedString("ACE", comment: "")
        case Takumaki:
            return NSLocalizedString("焚巻", comment: "")
        case Mrq:
            return NSLocalizedString("Mr.Q", comment: "")
        default:
            return ""
        }
    }

    var query: String {
        switch self {
        case Saue:
            return NSLocalizedString("上野", comment: "")
        case Kan:
            return NSLocalizedString("漢", comment: "")
        case Tpablow:
            return NSLocalizedString("T-p", comment: "")
        case Rshitei:
            return NSLocalizedString("R-指定", comment: "")
        case Chico:
            return NSLocalizedString("CHICO", comment: "")
        case Dotama:
            return NSLocalizedString("DOTAMA", comment: "")
        case Ace:
            return NSLocalizedString("ACE", comment: "")
        case Takumaki:
            return NSLocalizedString("焚巻", comment: "")
        case Mrq:
            return NSLocalizedString("Mr.Q", comment: "")
        default:
            return ""
        }
    }

    var segueID: String? {
        switch self {
        default:
            return nil
        }
    }
    
    var contentsMode: VideoListViewController.Mode? {
        switch self {
        case Saue, Kan, Tpablow, Rshitei, Chico, Dotama, Ace,Takumaki, Mrq:
            return VideoListViewController.Mode.Rapper
        default:
            return nil
        }
    }
}

private enum SettingDataSettingRow: Int {
    case Request
    case Copyright
    case Deliverd
    
    case DevMode
    case DevChannel
    case DevAutoDeliver
    case NumberOfRows
    
    
    var numberOfRows: Int {
        if Config.isNotDevMode() {
            return DevMode.rawValue
        }
        else {
            return NumberOfRows.rawValue
        }
    }
    
    var title: String {
        switch self {
        case .Request:
            return NSLocalizedString("setting_request", comment: "")
        case .Copyright:
            return NSLocalizedString("setting_licence", comment: "")
        case .Deliverd:
            return NSLocalizedString("setting_deliverd", comment: "")
        case .DevMode:
            if Config.isNotDevMode() {
                return ""
            }
            else {
                return NSLocalizedString("setting_toolmode", comment: "")
            }
        case DevChannel:
            if Config.isNotDevMode() {
                return ""
            }
            else {
                return NSLocalizedString("登録チャンネル", comment: "")
            }
        case DevAutoDeliver:
            if Config.isNotDevMode() {
                return ""
            }
            else {
                return NSLocalizedString("自動入稿", comment: "")
            }
        case .NumberOfRows:
            return ""
        }
    }
    
    var segueID: String? {
        switch self {
        case .Request:
            return nil
        case .Copyright:
            return "SettingToLicence"
        case .Deliverd:
            return nil
        case .DevMode:
            return nil
        case DevChannel:
            return "SettingToChannel"
        case DevAutoDeliver:
            return nil
        case .NumberOfRows:
            return nil
        }
    }
    
    var contentsMode: VideoListViewController.Mode? {
        return nil
    }
}

