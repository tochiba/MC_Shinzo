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
    static let localizedCategory: [String] = ["dog", "cat", "rabbit", "hamster", "hedgehog", "ferret", "parakeet", "penguin"]
    static let category: [String] = ["犬", "ネコ", "うさぎ", "ハムスター", "ハリネズミ", "フェレット", "インコ", "ペンギン"]
    static let categoryColor: [UIColor] = [
        UIColor(red: 251/255, green: 252/255, blue: 149/255, alpha: 1.0),
        UIColor(red: 252/255, green: 150/255, blue: 149/255, alpha: 1.0),
        UIColor(red: 149/255, green: 218/255, blue: 252/255, alpha: 1.0),
        UIColor(red: 149/255, green: 252/255, blue: 197/255, alpha: 1.0),
        UIColor(red: 252/255, green: 182/255, blue: 106/255, alpha: 1.0),
        UIColor(red: 246/255, green: 175/255, blue:  32/255, alpha: 1.0)]
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
                color: UIColor(red: 138/255, green: 200/255, blue: 135/255, alpha: 0.4)),
                NSLocalizedString(lstr, comment: "")))
        }
        
        tc.tabItems.append((VideoListViewController.getInstanceWithMode(.Favorite), NSLocalizedString("category_favorite", comment: "")))
        tc.tabItems.append((SettingViewController.getInstance(),
            NSLocalizedString("category_setting", comment: "")))
        
        var option = TabPageOption()
        option.currentColor = UIColor(red: 138/255, green: 200/255, blue: 135/255, alpha: 1.0)
        tc.option = option
        self.tabPageViewController = tc
    }
}
