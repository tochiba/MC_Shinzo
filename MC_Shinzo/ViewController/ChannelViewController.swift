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
    private var channels: [Channel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NIFTYManager.sharedInstance.loadDeliveredChannels(self)
    }
    @IBAction func didPushDoneButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ChannelViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpTransitionAnimater(presenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopUpTransitionAnimater(presenting: false)
    }
}


extension ChannelViewController {
    private func loadData() {
        self.channels = NIFTYManager.sharedInstance.getChannels()
        self.tableView.reloadData()
    }
}
extension ChannelViewController: NIFTYManagerChannelDelegate {
    func didLoadChannel() {
        dispatch_async(dispatch_get_main_queue(), {
            self.loadData()
        })
    }
}

extension ChannelViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let c = self.channels[indexPath.row]
        let vc = VideoListViewController.getInstanceWithMode(c.channelId, title: c.channelName, mode: .Channel)
        let nvc = AnimationNavigationController(rootViewController: vc)
        self.presentViewController(nvc, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let c = self.channels[indexPath.row]
            NIFTYManager.sharedInstance.deleteThisChannel(c, aDelegate: self)
        }
    }
}

extension ChannelViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingCell", forIndexPath: indexPath)
        let c = self.channels[indexPath.row]
        cell.textLabel?.text = c.channelName
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = Config.baseColor()
        return cell
    }
    
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
