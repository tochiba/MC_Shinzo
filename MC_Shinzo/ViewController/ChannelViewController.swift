//
//  ChannelViewController.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/05/15.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit

class ChannelViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    fileprivate var channels: [Channel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NIFTYManager.sharedInstance.loadDeliveredChannels(self)
    }
    @IBAction func didPushDoneButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChannelViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpTransitionAnimater(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpTransitionAnimater(presenting: false)
    }
}


extension ChannelViewController {
    fileprivate func loadData() {
        self.channels = NIFTYManager.sharedInstance.getChannels()
        self.tableView.reloadData()
    }
}
extension ChannelViewController: NIFTYManagerChannelDelegate {
    func didLoadChannel() {
        DispatchQueue.main.async(execute: {
            self.loadData()
        })
    }
}

extension ChannelViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let c = self.channels[indexPath.row]
        let vc = VideoListViewController.getInstanceWithMode(query: c.channelId, title: c.channelName, mode: .Channel)
        let nvc = AnimationNavigationController(rootViewController: vc)
        self.present(nvc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let c = self.channels[indexPath.row]
            NIFTYManager.sharedInstance.deleteThisChannel(c, aDelegate: self)
        }
    }
}

extension ChannelViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        let c = self.channels[indexPath.row]
        cell.textLabel?.text = c.channelName
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = Config.baseColor()
        return cell
    }
    
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
