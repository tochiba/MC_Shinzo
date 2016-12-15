//
//  ViewController.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/03/26.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import TabPageViewController

struct VideoCategory {
    static let localizedCategory: [String] = ["popular_mc", "rookie_mc", "rhyming", "flow", "punchLine", "vibes"]
    static let category: [String] = ["PopularMC", "RookieMC", "Rhyming", "Flow", "PunchLine", "Vibes"]
}

class ViewController: UIViewController {

    var tabPageViewController :TabPageViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sendScreenNameLog()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let tpvc = self.tabPageViewController {
            let nc = self.navigationController!
            nc.viewControllers = [tpvc]
            self.present(nc, animated: false, completion: nil)
        }
        else {
            setupPageViewController()
        }
    }
}

extension ViewController {
    fileprivate func setupPageViewController() {
        let tc = TabPageViewController.create()
        tc.isInfinity = true
        let image = UIImage(named: "nav_header_logo")
        let imageView = UIImageView(image: image)
        tc.navigationItem.titleView = imageView
      
        tc.tabItems.append((VideoListViewController.getInstanceWithMode(mode: .New),
            NSLocalizedString("category_new", comment: "")))
        tc.tabItems.append((VideoListViewController.getInstanceWithMode(mode: .Popular),
            NSLocalizedString("category_popular", comment: "")))
        
        for tuple in VideoCategory.category.enumerated() {
            let lstr = VideoCategory.localizedCategory[tuple.offset]
            tc.tabItems.append((VideoListViewController.getInstance(query: tuple.element),
                NSLocalizedString(lstr, comment: "")))
        }
        
        tc.tabItems.append((VideoListViewController.getInstanceWithMode(mode: .Favorite), NSLocalizedString("category_favorite", comment: "")))
        tc.tabItems.append((SettingViewController.getInstance(),
            NSLocalizedString("category_setting", comment: "")))
        
        var option = TabPageOption()
        option.currentColor = Config.keyColor()
        option.tabBackgroundColor = Config.baseColor()
        tc.option = option
        self.tabPageViewController = tc
    }
}
