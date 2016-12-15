//
//  LicenceViewController.swift
//  MC_Shinzo
//
//  Created by 千葉 俊輝 on 2016/04/09.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit


class LicenceViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var _string = ""
        for tuple in MITLicenceData.libName.enumerated() {
            _string += tuple.element + MITLicenceData.newLine + MITLicenceData.header + MITLicenceData.newLine + MITLicenceData.copyright + MITLicenceData.libCopyright[tuple.offset] + MITLicenceData.newLine + MITLicenceData.body + MITLicenceData.newLine
        }
        
        self.textView.text = _string
    }
    @IBAction func didPushDone(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

private struct MITLicenceData {
    static let newLine = "\n\n"
    static let libName: [String] = ["XCDYouTubeKit", "SwiftRefresher", "SDWebImage", "TabPageViewController", "Alamofire", "SwiftyJSON"]
    static let libCopyright: [String] = ["2013-2016 Cédric Luthi", "2015 Morita Naoki", "2016 Olivier Poitrey rs@dailymotion.com", "2016 EndouMari <endo@vasily.jp>", "2014–2016 Alamofire Software Foundation (http://alamofire.org/)", "2014 Ruoyu Fu"]
    
    static let header = "The MIT License (MIT)"
    static let copyright = "Copyright (c) "
    static let body = "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
}
