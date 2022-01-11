//
//  SettingsInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by Hugo on 05/12/2021.
//

import WatchKit
import Foundation
import Alamofire

class SettingsInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var cacheToggle: WKInterfaceSwitch!
    @IBOutlet weak var cacheDeleteButton: WKInterfaceButton!
    @IBOutlet weak var thumbnailsToggle: WKInterfaceSwitch!
    @IBOutlet weak var audioOnlyToggle: WKInterfaceSwitch!
    @IBOutlet weak var resultsLabel: WKInterfaceLabel!
    @IBOutlet weak var itemsLabel: WKInterfaceLabel!
    @IBOutlet weak var homeVideosPicker: WKInterfacePicker!
    @IBOutlet weak var instancePicker: WKInterfacePicker!
    @IBOutlet weak var instanceStatus: WKInterfaceLabel!
    
    let userDefaults = UserDefaults.standard
    
    var videoTypes: [String] = [
        "default",
        "music",
        "gaming",
        "news",
        "channels"
    ]
    
    var instances: Array<String> = []

    @IBAction func cacheToggle(_ value: Bool) {
        if value == true {
            userDefaults.set(value, forKey: settingsKeys.cacheToggle)
            cacheDeleteButton.setHidden(false)
            
            willActivate()

        }
        else {
            do {
                var totalSize = 0 as Int64
                let files = try FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory()+"/Documents/cache/")
                for file in files {
                    if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: NSHomeDirectory()+"/Documents/cache/\(file)") {
                        if let bytes = fileAttributes[.size] as? Int64 {
                            totalSize = totalSize+bytes
                        }
                    }
                }
                let bcf = ByteCountFormatter()
                if ((totalSize >= 1024000000) == true) {bcf.allowedUnits = [.useGB]} else {bcf.allowedUnits = [.useMB]}
                bcf.countStyle = .file
                let string = bcf.string(fromByteCount: totalSize)
                
                if totalSize != 0 {
                    let action1 = WKAlertAction(title: "Delete And Turn Off", style: .destructive) { [weak self] in
                        self!.userDefaults.set(value, forKey: settingsKeys.cacheToggle)
                        
                        do {
                            let files = try FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory()+"/Documents/cache")
                            for file in files {
                                try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Documents/cache/\(file)")
                            }
                        } catch {
                            //what happened lol
                        }
                        do {
                            let files = try FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory()+"/Documents/miscCache")
                            for file in files {
                                try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Documents/miscCache/\(file)")
                            }
                        } catch {
                            //what happened lol
                        }
                        self!.cacheDeleteButton.setHidden(true)
                    }
                    let action2 = WKAlertAction(title: "Cancel", style: .cancel) { [weak self] in
                        self!.cacheToggle.setOn(true)
                    }
                    presentAlert(withTitle: "Warning", message: "You currently have \(string) of cache, are you sure you want to turn off caching?", preferredStyle: .alert, actions: [action1, action2])
                } else {
                    userDefaults.set(value, forKey: settingsKeys.cacheToggle)
                    cacheDeleteButton.setHidden(true)
                }
            } catch {
                //thonk
            }
        }
    }
    
    @IBAction func deleteCacheButton() {
        
        let action1 = WKAlertAction(title: "Delete Cache", style: .destructive) { [weak self] in
            
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory()+"/Documents/cache")
                for file in files {
                    try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Documents/cache/\(file)")
                }
                self!.cacheDeleteButton.setTitle("Cleared")
                self!.cacheDeleteButton.setEnabled(false)
            } catch {
                //what happened lol
            }
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory()+"/Documents/miscCache")
                for file in files {
                    try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Documents/miscCache/\(file)")
                }
            } catch {
                //what happened lol
            }
        }
        
        let action2 = WKAlertAction(title: "Cancel", style: .cancel) {}
        
        presentAlert(withTitle: "Delete Cache?", message: "Are you sure you want to delete the cache?", preferredStyle: .alert, actions: [action1, action2])
    }
    
    @IBAction func thumbnailsToggle(_ value: Bool) {
        userDefaults.set(value, forKey: settingsKeys.thumbnailsToggle)
    }
    
    @IBAction func audioOnlyToggle(_ value: Bool) {
        userDefaults.set(value, forKey: settingsKeys.audioOnlyToggle)
    }
    
    @IBAction func resultLower() {
        if userDefaults.integer(forKey: settingsKeys.resultsCount) > 3 {
            userDefaults.set(userDefaults.value(forKey: settingsKeys.resultsCount) as! Int-1, forKey: settingsKeys.resultsCount)
            updateLabel()
        }
    }
    
    @IBAction func resultHigher() {
        if userDefaults.integer(forKey: settingsKeys.resultsCount) < 30 {
            userDefaults.set(userDefaults.value(forKey: settingsKeys.resultsCount) as! Int+1, forKey: settingsKeys.resultsCount)
            updateLabel()
        }
    }
    
    @IBAction func itemLower() {
        if userDefaults.integer(forKey: settingsKeys.itemsCount) > 5 {
            userDefaults.set(userDefaults.value(forKey: settingsKeys.itemsCount) as! Int-1, forKey: settingsKeys.itemsCount)
            updateLabel()
        }
    }
    
    @IBAction func itemHigher() {
        if userDefaults.integer(forKey: settingsKeys.itemsCount) < 80 {
            userDefaults.set(userDefaults.value(forKey: settingsKeys.itemsCount) as! Int+1, forKey: settingsKeys.itemsCount)
            updateLabel()
        }
    }
    
    func updateLabel() {
        resultsLabel.setText("\(String(describing: userDefaults.value(forKey: settingsKeys.resultsCount) as! Int)) Results")
        itemsLabel.setText("\(String(describing: userDefaults.value(forKey: settingsKeys.itemsCount) as! Int)) Items")
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }

    override func willActivate() {
        
        // set the picker items up
        let pickerItems: [WKPickerItem] = videoTypes.map {
            let pickerItem = WKPickerItem()
            pickerItem.title = $0.capitalizingFirstLetter()
            return pickerItem
        }
        homeVideosPicker.setItems(pickerItems)
        
        // set all the properties of settings to match userdefaults
        homeVideosPicker.setSelectedItemIndex(Int(videoTypes.firstIndex(of: userDefaults.string(forKey: settingsKeys.homePageVideoType)!)!))
        cacheToggle.setOn(userDefaults.bool(forKey: settingsKeys.cacheToggle))
        thumbnailsToggle.setOn(userDefaults.bool(forKey: settingsKeys.thumbnailsToggle))
        audioOnlyToggle.setOn(userDefaults.bool(forKey: settingsKeys.audioOnlyToggle))
        cacheDeleteButton.setHidden(!userDefaults.bool(forKey: settingsKeys.cacheToggle))
        
        // set cache button to enabled, if its empty just keep it as cleared and disable it
        cacheDeleteButton.setEnabled(true)
        do {
            var totalSize = 0 as Int64
            let files = try FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory()+"/Documents/cache/")
            for file in files {
                if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: NSHomeDirectory()+"/Documents/cache/\(file)") {
                    if let bytes = fileAttributes[.size] as? Int64 {
                        totalSize = totalSize+bytes
                    }
                }
            }
            let bcf = ByteCountFormatter()
            if ((totalSize >= 1024000000) == true) {bcf.allowedUnits = [.useGB]} else {bcf.allowedUnits = [.useMB]}
            bcf.countStyle = .file
            let string = bcf.string(fromByteCount: totalSize)
            if totalSize == 0 {
                cacheDeleteButton.setEnabled(false)
                cacheDeleteButton.setTitle("Cleared")
            } else {
                cacheDeleteButton.setTitle("Clear Cache (\(string))")
            }
        } catch {
            cacheDeleteButton.setEnabled(false)
            cacheDeleteButton.setTitle("Cleared")
        }
        
        updateLabel()

        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        AF.request("https://api.invidious.io/instances.json").responseJSON { res in
            switch res.result {
            case .success(let json):
                self.instances = []
                
                let data = json as! Array<Array<Any>>
                for inst in data {
                    let name = inst[0] as! String
                    let info = inst[1] as! Dictionary<String, Any>
                    if info["type"] as! String != "https" {continue}
                    self.instances.append(name)
                }
                
                let instanceItems: [WKPickerItem] = self.instances.map {
                    let pickerItem = WKPickerItem()
                    pickerItem.title = $0
                    return pickerItem
                }
                self.instancePicker.setItems(instanceItems)
                self.instancePicker.setSelectedItemIndex(Int(self.instances.firstIndex(of: UserDefaults.standard.string(forKey: settingsKeys.instanceUrl)!)!))
            case .failure(_):
                break
            }
        }
    }
    
    @IBAction func selectInstance(_ value: Int) {
        self.instancePicker.setEnabled(false)
        self.instanceStatus.setTextColor(.lightGray)
        self.instanceStatus.setText("Loading...")
        AF.request("https://\(instances[value])/api/v1/search?q=e").validate().responseJSON {resp in
            switch resp.result {
            case .success(_):
                self.instancePicker.setEnabled(true)
                
                self.instanceStatus.setTextColor(.green)
                self.instanceStatus.setText("\(self.instances[value]) works")
                self.userDefaults.set(self.instances[value], forKey: settingsKeys.instanceUrl)
            case .failure(_):
                self.instancePicker.setEnabled(true)

                self.instanceStatus.setTextColor(.red)
                self.instanceStatus.setText("\(self.instances[value]) is broken")
                break
            }
        }
    }
    
    @IBAction func homeVideosSelection(_ value: Int) {
        userDefaults.set(videoTypes[value], forKey: settingsKeys.homePageVideoType)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
