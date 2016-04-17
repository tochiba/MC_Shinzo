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

    class func baseColor(alpha: CGFloat=1.0) -> UIColor {
        return UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: alpha)
    }
    
    class func keyColor(alpha: CGFloat=1.0) -> UIColor {
//        return UIColor(red: 230/255, green: 180/255, blue: 35/255, alpha: alpha)
//        return UIColor(red: 230/255, green: 115/255, blue: 100/255, alpha: alpha)
//        return UIColor(red: 92/255, green: 159/255, blue: 40/255, alpha: alpha)
        return UIColor(red: 219/255, green: 228/255, blue: 153/255, alpha: alpha)
    }
}