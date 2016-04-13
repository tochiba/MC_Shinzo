//
//  Config.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/04/03.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit

class Config {
    private struct Key {
        static let devModeKey = "DevMode"
    }
    
    class func isNotDevMode() -> Bool {
        let d = NSUserDefaults.standardUserDefaults()
        return !d.boolForKey(Key.devModeKey)
    }
    class func setDevMode(isMode: Bool) {
        let d = NSUserDefaults.standardUserDefaults()
        d.setBool(isMode, forKey: Key.devModeKey)
    }

    class func keyColor(alpha: CGFloat=1.0) -> UIColor {
        return UIColor(red: 138/255, green: 200/255, blue: 135/255, alpha: alpha)
    }
}