//
//  ViewController.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/03/26.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import TabPageViewController

// TODO:
/*
人気MC対決
新人MC対決
ライミング
フロー
ビートアプローチ
パンチライン
バイブス
*/

struct VideoCategory {
    static let localizedCategory: [String] = ["dog", "cat", "rabbit", "hamster", "hedgehog", "ferret", "parakeet", "penguin"]
    static let category: [String] = ["犬", "ネコ", "うさぎ", "ハムスター", "ハリネズミ", "フェレット", "インコ", "ペンギン"]
}

class ViewController: UIViewController {

    var tabPageViewController :TabPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let tpvc = self.tabPageViewController {
            let nc = self.navigationController!
            nc.viewControllers = [tpvc]
            self.presentViewController(nc, animated: false, completion: nil)
        }
        else {
            setupPageViewController()
        }
    }
}

extension ViewController {
    private func setupPageViewController() {
        let tc = TabPageViewController.create()
        tc.isInfinity = true
        let image = UIImage(named: "nav_header_logo")
        let imageView = UIImageView(image: image)
        tc.navigationItem.titleView = imageView
      
        tc.tabItems.append((VideoListViewController.getInstanceWithMode(.Popular),
            NSLocalizedString("category_popular", comment: "")))
        tc.tabItems.append((VideoListViewController.getInstanceWithMode(.New),
            NSLocalizedString("category_new", comment: "")))
        
        for tuple in VideoCategory.category.enumerate() {
            let lstr = VideoCategory.localizedCategory[tuple.index]
            tc.tabItems.append((VideoListViewController.getInstance(tuple.element,
                color: Config.keyColor(0.4)),
                NSLocalizedString(lstr, comment: "")))
        }
        
        tc.tabItems.append((VideoListViewController.getInstanceWithMode(.Favorite), NSLocalizedString("category_favorite", comment: "")))
        tc.tabItems.append((SettingViewController.getInstance(),
            NSLocalizedString("category_setting", comment: "")))
        
        var option = TabPageOption()
        option.currentColor = Config.keyColor()
        tc.option = option
        self.tabPageViewController = tc
    }
}
