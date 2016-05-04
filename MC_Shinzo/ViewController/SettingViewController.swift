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

class SettingViewController: UIViewController {
    @IBOutlet weak var tableView: SettingTableView!
    @IBOutlet weak var bannerView: BannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bannerView.setup(self, unitID: AD.BannerUnitID)
    }
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
            // Timer生成
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
}

extension SettingViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let segue = SettingData(rawValue: indexPath.row)?.segueID {
            self.performSegueWithIdentifier(segue, sender: nil)
        }
        else if SettingData(rawValue: indexPath.row) == .Request {
            Meyasubaco.showCommentViewController(self)
        }
        else if SettingData(rawValue: indexPath.row) == .DevMode {
            if !Config.isNotDevMode() {
                let vc = VideoListViewController.getInstanceWithMode(mode: .Draft)
                let nvc = UINavigationController(rootViewController: vc)
                self.presentViewController(nvc, animated: true, completion: nil)
            }
        }
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingData(rawValue: section)!.numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SettingData.cellName, forIndexPath: indexPath)
        cell.textLabel?.text = SettingData(rawValue: indexPath.row)?.title
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = Config.baseColor()
        return cell
    }
}

private enum SettingData: Int {
    case Request
    case Copyright
    case DevMode
    case NumberOfRows
    
    static let cellName = "SettingCell"
    
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
        case .Request:
            return NSLocalizedString("setting_request", comment: "")
        case .Copyright:
            return NSLocalizedString("setting_licence", comment: "")
        case .DevMode:
            if Config.isNotDevMode() {
                return ""
            }
            else {
                return NSLocalizedString("setting_toolmode", comment: "")
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
        case .DevMode:
            return nil
        case .NumberOfRows:
            return nil
        }
    }
}
