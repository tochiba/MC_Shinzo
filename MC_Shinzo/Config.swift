//
//  Config.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/04/03.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation

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
}