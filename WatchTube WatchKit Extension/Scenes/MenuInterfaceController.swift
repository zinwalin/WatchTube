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
            self.pushController(withName: "CacheContentsInterfaceController", context: "Any")
        }
        else {
            cacheScreenButton.setEnabled(false)
        }
    }
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
