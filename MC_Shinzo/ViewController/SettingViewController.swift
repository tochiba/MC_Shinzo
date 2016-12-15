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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    var timer: Timer = Timer()
    var counter: Int = 0
    weak var viewController: UIViewController?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if self.timer.isValid {
            self.counter += 1
        }
        else {
            self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(SettingTableView.resetTimer), userInfo: nil, repeats: false)
        }
        check()
    }
    
    func resetTimer() {
        self.counter = 0
        self.timer.invalidate()
    }
    
    fileprivate func check() {
        if self.counter > 11 {
            
            let alert: UIAlertController = UIAlertController(title:"Dev Mode",
                                                            message: "Input Password",
                                                            preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
                                                           style: UIAlertActionStyle.cancel,
                                                           handler:{
                                                            (action:UIAlertAction!) -> Void in
            })
            let defaultAction:UIAlertAction = UIAlertAction(title: "OK",
                                                            style: UIAlertActionStyle.default,
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
            
            alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                text.placeholder = "password"
                let label:UILabel = UILabel(frame: CGRect(x:0, y:0, width:50, height:30))
                label.text = "PASS"
                text.leftView = label
                text.leftViewMode = UITextFieldViewMode.always
                
            })
            self.viewController?.present(alert, animated: true, completion: nil)
        }
    }
}

extension SettingViewController {
    class func getInstance() -> SettingViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController {
            vc.view.backgroundColor = Config.baseColor()
            vc.tableView.backgroundColor = Config.baseColor()
            return vc
        }
        
        return self.init()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bannerView.setup(self, unitID: AD.DrawerBannerUnitID)
        self.tableView.viewController = self
        self.sendScreenNameLog()
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let sdata = SettingDataSection(rawValue: indexPath.section)
        
        if sdata == .menu {
            if let mode = SettingDataMenuRow(rawValue: indexPath.row)?.contentsMode {
                self.delegate?.didSelectCell(mode, query: "")
            }
            
            return
        }
        
        if sdata == .event {
            guard let rdata = SettingDataEventRow(rawValue: indexPath.row) else {
                return
            }
            if let mode = rdata.contentsMode {
                self.delegate?.didSelectCell(mode, query: rdata.query)
            }
            
            return
        }

        if sdata == .rapper {
            guard let rdata = SettingDataRapperRow(rawValue: indexPath.row) else {
                return
            }
            if let mode = rdata.contentsMode {
                self.delegate?.didSelectCell(mode, query: rdata.query)
            }
            
            return
        }
        
        if sdata == .setting {
            let data = SettingDataSettingRow(rawValue: indexPath.row)
            if let segue = data?.segueID {
                if data != .devChannel {
                    self.performSegue(withIdentifier: segue, sender: nil)
                }
                else if !Config.isNotDevMode() {
                    self.performSegue(withIdentifier: segue, sender: nil)
                }
            }
            else if data == .request {
                Meyasubaco.showCommentViewController(self)
            }
            else if data == .deliverd {
                let url = Foundation.URL(string: URL.Twitter)!
                let brow = SFSafariViewController(url: url, entersReaderIfAvailable: false)
                brow.delegate = self
                present(brow, animated: true, completion: nil)
            }
            else if data == .review {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let nVC = storyboard.instantiateViewController(withIdentifier: "ReviewController") as? ReviewController {
                    nVC.delegate = self
                    nVC.showCloseButton = true
                    self.present(nVC, animated: true, completion: nil)
                }
            }
            else if data == .devMode {
                if !Config.isNotDevMode() {
                    let vc = VideoListViewController.getInstanceWithMode(mode: .Draft)
                    let nvc = UINavigationController(rootViewController: vc)
                    self.present(nvc, animated: true, completion: nil)
                }
            }
            else if data == .devAutoDeliver {
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0,y: 0,width: tableView.frame.size.width,height: 50))
        label.textColor = UIColor.lightGray
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.text = SettingDataSection(rawValue: section)?.title
        return label
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return SettingDataSection(rawValue: section)?.title
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingDataSection(rawValue: section)?.heightOfSections ?? 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingDataSection.NumberOfSections.numberOfSections
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingDataSection(rawValue: section)!.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sdata = SettingDataSection(rawValue: indexPath.section)! as SettingDataSection
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingDataSection.cellName, for: indexPath)
        var text: String? = ""
        switch sdata {
        case .menu:
            text = SettingDataMenuRow(rawValue: indexPath.row)?.title
            break
        case .event:
            text = SettingDataEventRow(rawValue: indexPath.row)?.title
            break
        case .rapper:
            text = SettingDataRapperRow(rawValue: indexPath.row)?.title
            break
        case .setting:
            text = SettingDataSettingRow(rawValue: indexPath.row)?.title
            break
        default:
            break
        }
        cell.textLabel?.text = text
        cell.textLabel?.textColor = UIColor.white
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

extension SettingViewController: SFSafariViewControllerDelegate {
}

private enum SettingDataSection: Int {
    case menu
    case event
    case rapper
    case setting
    case NumberOfSections
    
    static let cellName = "SettingCell"

    var numberOfSections: Int {
        return SettingDataSection.NumberOfSections.rawValue
    }
    
    var heightOfSections: CGFloat {
        return 50 //self == .Setting ? 30 : 0
    }
    
    var numberOfRows: Int {
        switch self {
        case .menu:
            return SettingDataRow.favorite.rawValue + 1
        case .event:
            return SettingDataEventRow.freestyle.numberOfRows
        case .rapper:
            return SettingDataRapperRow.dotama.numberOfRows
        case .setting:
            return SettingDataSettingRow.deliverd.numberOfRows
        default:
            return 0
        }
    }
    
    var title: String {
        switch self {
        case .menu:
            return "    " + NSLocalizedString("setting_menu", comment: "")
        case .event:
            return "    " + NSLocalizedString("setting_event", comment: "")
        case .rapper:
            return "    " + NSLocalizedString("setting_rapper", comment: "")
        case .setting:
            return "    " + NSLocalizedString("category_setting", comment: "")
        default:
            return ""
        }
    }
    
    fileprivate enum SettingDataRow: Int {
        case new
        case popular
        case favorite
        
        case request
        case copyright
        case deliverd
        
        case devMode
        case devChannel
        case devAutoDeliver
        case NumberOfRows
        

        var numberOfRows: Int {
            if Config.isNotDevMode() {
                return SettingDataRow.NumberOfRows.rawValue-1
            }
            else {
                return SettingDataRow.NumberOfRows.rawValue
            }
        }
        
        var title: String {
            switch self {
            case .new:
                return NSLocalizedString("category_new", comment: "")
            case .popular:
                return NSLocalizedString("category_popular", comment: "")
            case .favorite:
                return NSLocalizedString("category_favorite", comment: "")
            case .request:
                return NSLocalizedString("setting_request", comment: "")
            case .copyright:
                return NSLocalizedString("setting_licence", comment: "")
            case .deliverd:
                return NSLocalizedString("setting_deliverd", comment: "")
            case .devMode:
                if Config.isNotDevMode() {
                    return ""
                }
                else {
                    return NSLocalizedString("setting_toolmode", comment: "")
                }
            case .devChannel:
                if Config.isNotDevMode() {
                    return ""
                }
                else {
                    return NSLocalizedString("登録チャンネル", comment: "")
                }
            case .devAutoDeliver:
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
            case .new:
                return nil
            case .popular:
                return nil
            case .favorite:
                return nil
            case .request:
                return nil
            case .copyright:
                return "SettingToLicence"
            case .deliverd:
                return nil
            case .devMode:
                return nil
            case .devChannel:
                return "SettingToChannel"
            case .devAutoDeliver:
                return nil
            case .NumberOfRows:
                return nil
            }
        }
        
        var contentsMode: VideoListViewController.Mode? {
            switch self {
            case .new:
                return VideoListViewController.Mode.New
            case .popular:
                return VideoListViewController.Mode.Popular
            case .favorite:
                return VideoListViewController.Mode.Favorite
            default:
                return nil
            }
        }
    }
}

private enum SettingDataMenuRow: Int {
    case new
    case popular
    case favorite
    case NumberOfRows
    
    var numberOfRows: Int {
        return SettingDataMenuRow.NumberOfRows.rawValue
    }
    var title: String {
        switch self {
        case .new:
            return NSLocalizedString("category_new", comment: "")
        case .popular:
            return NSLocalizedString("category_popular", comment: "")
        case .favorite:
            return NSLocalizedString("category_favorite", comment: "")
        default:
            return ""
        }
    }
    
    var segueID: String? {
        switch self {
        case .new:
            return nil
        case .popular:
            return nil
        case .favorite:
            return nil
        default:
            return nil
        }
    }
    
    var contentsMode: VideoListViewController.Mode? {
        switch self {
        case .new:
            return VideoListViewController.Mode.New
        case .popular:
            return VideoListViewController.Mode.Popular
        case .favorite:
            return VideoListViewController.Mode.Favorite
        default:
            return nil
        }
    }
}

private enum SettingDataEventRow: Int {
    case freestyle
    case koukousei
    case umb
    case sengoku
    case NumberOfRows
    
    var numberOfRows: Int {
        return SettingDataEventRow.NumberOfRows.rawValue
    }
    var title: String {
        switch self {
        case .freestyle:
            return NSLocalizedString("フリースタイルダンジョン", comment: "")
        case .koukousei:
            return NSLocalizedString("高校生ラップ選手権", comment: "")
        case .umb:
            return NSLocalizedString("UMB", comment: "")
        case .sengoku:
            return NSLocalizedString("戦極MC BATTLE", comment: "")
        default:
            return ""
        }
    }
    
    var query: String {
        switch self {
        case .freestyle:
            return NSLocalizedString("フリースタイルダンジョン", comment: "")
        case .koukousei:
            return NSLocalizedString("高校生", comment: "")
        case .umb:
            return NSLocalizedString("UMB", comment: "")
        case .sengoku:
            return NSLocalizedString("戦極MC", comment: "")
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
        case .NumberOfRows:
            return nil
        default:
            return VideoListViewController.Mode.Rapper
        }
    }
}

private enum SettingDataRapperRow: Int {
    case saue
    case kan
    case tpablow
    case rshitei
    case chico
    case dotama
    case ace
    case takumaki
    case chin
    case NumberOfRows
    
    var numberOfRows: Int {
        return SettingDataRapperRow.NumberOfRows.rawValue
    }
    var title: String {
        switch self {
        case .saue:
            return NSLocalizedString("サイプレス上野", comment: "")
        case .kan:
            return NSLocalizedString("漢 a.k.a GAMI", comment: "")
        case .tpablow:
            return NSLocalizedString("T-PABLOW", comment: "")
        case .rshitei:
            return NSLocalizedString("R-指定", comment: "")
        case .chico:
            return NSLocalizedString("CHICO CARLITO", comment: "")
        case .dotama:
            return NSLocalizedString("DOTAMA", comment: "")
        case .ace:
            return NSLocalizedString("ACE", comment: "")
        case .takumaki:
            return NSLocalizedString("焚巻", comment: "")
        case .chin:
            return NSLocalizedString("鎮座DOPENESS", comment: "")
        default:
            return ""
        }
    }

    var query: String {
        switch self {
        case .saue:
            return NSLocalizedString("上野", comment: "")
        case .kan:
            return NSLocalizedString("漢", comment: "")
        case .tpablow:
            return NSLocalizedString("T-p", comment: "")
        case .rshitei:
            return NSLocalizedString("R-指定", comment: "")
        case .chico:
            return NSLocalizedString("CHICO", comment: "")
        case .dotama:
            return NSLocalizedString("DOTAMA", comment: "")
        case .ace:
            return NSLocalizedString("ACE", comment: "")
        case .takumaki:
            return NSLocalizedString("焚巻", comment: "")
        case .chin:
            return NSLocalizedString("鎮座", comment: "")
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
        case .saue, .kan, .tpablow, .rshitei, .chico, .dotama, .ace,.takumaki, .chin:
            return VideoListViewController.Mode.Rapper
        default:
            return nil
        }
    }
}

private enum SettingDataSettingRow: Int {
    case request
    case copyright
    case deliverd
    case review
    
    case devMode
    case devChannel
    case devAutoDeliver
    case NumberOfRows
    
    
    var numberOfRows: Int {
        if Config.isNotDevMode() {
            return SettingDataSettingRow.devMode.rawValue
        }
        else {
            return SettingDataSettingRow.NumberOfRows.rawValue
        }
    }
    
    var title: String {
        switch self {
        case .request:
            return NSLocalizedString("setting_request", comment: "")
        case .copyright:
            return NSLocalizedString("setting_licence", comment: "")
        case .deliverd:
            return NSLocalizedString("setting_deliverd", comment: "")
        case .review:
            return NSLocalizedString("setting_review", comment: "")
        case .devMode:
            if Config.isNotDevMode() {
                return ""
            }
            else {
                return NSLocalizedString("setting_toolmode", comment: "")
            }
        case .devChannel:
            if Config.isNotDevMode() {
                return ""
            }
            else {
                return NSLocalizedString("登録チャンネル", comment: "")
            }
        case .devAutoDeliver:
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
        case .request:
            return nil
        case .copyright:
            return "SettingToLicence"
        case .deliverd:
            return nil
        case .review:
            return nil
        case .devMode:
            return nil
        case .devChannel:
            return "SettingToChannel"
        case .devAutoDeliver:
            return nil
        case .NumberOfRows:
            return nil
        }
    }
    
    var contentsMode: VideoListViewController.Mode? {
        return nil
    }
}

extension SettingViewController: ReviewControllerDelegate {
    func didPushFeedBackButton() {
        Meyasubaco.showCommentViewController(self)
    }
}

