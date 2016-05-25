//
//  MainViewController.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/05/24.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit
import KYDrawerController

protocol BaseControllerDelegate: class {
    func didSelectCell(mode: VideoListViewController.Mode)
}

class BaseViewController: KYDrawerController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        if let dvc = self.drawerViewController as? DrawerViewController {
            dvc.delegate = self
        }
    }
    deinit {
        self.delegate = nil
    }
}
extension BaseViewController: KYDrawerControllerDelegate {
    func drawerController(drawerController: KYDrawerController, stateChanged state: KYDrawerController.DrawerState) {
        
    }
}
extension BaseViewController: BaseControllerDelegate {
    func didSelectCell(mode: VideoListViewController.Mode) {
        self.setDrawerState(.Closed, animated: true)
        if let mvc = self.mainViewController as? MainViewController {
            mvc.mode = mode
            mvc.setData()
        }
    }
}

class MainViewController: VideoListViewController {
}
class DrawerViewController: SettingViewController {
}