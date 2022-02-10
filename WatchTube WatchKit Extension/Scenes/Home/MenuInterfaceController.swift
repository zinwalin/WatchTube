//
//  MenuInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by Hugo Mason on 20/12/2021.
//

import WatchKit
import Foundation


class MenuInterfaceController: WKInterfaceController {

    @IBAction func openSettingsButton() {
        self.pushController(withName: "SettingsInterfaceController", context: "")
    }
    
    @IBOutlet weak var cacheScreenButton: WKInterfaceButton!
    
    @IBAction func CacheScreen() {
        self.pushController(withName: "CacheContentsInterfaceController", context: "")
    }

    override func willActivate() {
        if UserDefaults.standard.bool(forKey: miscKeys.pushToCacheContents) == true {
            UserDefaults.standard.set(false, forKey: miscKeys.pushToCacheContents)
            pushController(withName: "CacheContentsInterfaceController", context: "")
        }
        if UserDefaults.standard.bool(forKey: miscKeys.isDebug) == true {
            cacheScreenButton.setHidden(false)
        } else {
            cacheScreenButton.setHidden(true)
        }
        super.willActivate()
    }

}
