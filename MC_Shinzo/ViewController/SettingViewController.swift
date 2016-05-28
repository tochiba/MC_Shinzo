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
    var delegate: BaseControllerDelegate?
}

class SettingTableView: UITableView {
    var timer: NSTimer = NSTimer()
    var counter: Int = 0

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
            Config.setDevMode(Config.isNotDevMode())
            self.reloadData()
            resetTimer()
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
        self.sendScreenNameLog()
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let sdata = SettingDataSection(rawValue: indexPath.section)
        
        if sdata == .Menu {
            if let mode = SettingDataMenuRow(rawValue: indexPath.row)?.contentsMode {
                self.delegate?.didSelectCell(mode)
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
                    AutoDeliverManager.sharedInstance.start()
                }
            }
            return
        }
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRectMake(0,0,tableView.frame.size.width,30))
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Left
        label.font = UIFont.systemFontOfSize(15)
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
        let sdata = SettingDataSection(rawValue: indexPath.section)
        let cell = tableView.dequeueReusableCellWithIdentifier(SettingDataSection.cellName, forIndexPath: indexPath)
        cell.textLabel?.text = sdata == .Menu ? SettingDataMenuRow(rawValue: indexPath.row)?.title:SettingDataSettingRow(rawValue: indexPath.row)?.title
        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
}

extension SettingViewController: SFSafariViewControllerDelegate {
}

private enum SettingDataSection: Int {
    case Menu
    case Setting
    case NumberOfSections
    
    static let cellName = "SettingCell"

    var numberOfSections: Int {
        return NumberOfSections.rawValue
    }
    
    var heightOfSections: CGFloat {
        return 30 //self == .Setting ? 30 : 0
    }
    
    var numberOfRows: Int {
        switch self {
        case .Menu:
            return SettingDataRow.Favorite.rawValue + 1
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

