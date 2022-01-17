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
        self.pushController(withName: "SettingsInterfaceController", context: "Any")
    }
    
    @IBOutlet weak var cacheScreenButton: WKInterfaceButton!
    
    @IBAction func CacheScreen() {
        if UserDefaults.standard.bool(forKey: settingsKeys.cacheToggle) == true {
            cacheScreenButton.setEnabled(true)
            self.pushController(withName: "CacheContentsInterfaceController", context: "")
        }
        else {
            cacheScreenButton.setEnabled(false)
        }
    }

    override func willActivate() {
        if UserDefaults.standard.bool(forKey: miscKeys.pushToCacheContents) == true {
            UserDefaults.standard.set(false, forKey: miscKeys.pushToCacheContents)
            pushController(withName: "CacheContentsInterfaceController", context: "")
        }
        
        super.willActivate()
        meta.cacheChannelInfo(udid: "UCYzPXprvl5Y-Sf0g4vX-m6g")
    }

}
