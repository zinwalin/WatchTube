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
    
    @IBOutlet weak var thumbnailsToggle: WKInterfaceSwitch!
    @IBOutlet weak var audioOnlyToggle: WKInterfaceSwitch!
    @IBOutlet weak var resultsLabel: WKInterfaceLabel!
    @IBOutlet weak var itemsLabel: WKInterfaceLabel!
    @IBOutlet weak var homeVideosPicker: WKInterfacePicker!
    @IBOutlet weak var instancePicker: WKInterfacePicker!
    @IBOutlet weak var proxyToggle: WKInterfaceSwitch!
    @IBOutlet weak var qualityToggle: WKInterfaceSwitch!
    @IBOutlet weak var instanceStatus: WKInterfaceLabel!
    
    let userDefaults = UserDefaults.standard
    
    var videoTypes: [String] = [
        "default",
        "music",
        "gaming",
        "news",
//        "channels"
    ]
    
    var instances: Array<String> = []
    
    @IBAction func thumbnailsToggle(_ value: Bool) {
        userDefaults.set(value, forKey: settingsKeys.thumbnailsToggle)
    }
    
    @IBAction func audioOnlyToggle(_ value: Bool) {
        userDefaults.set(value, forKey: settingsKeys.audioOnlyToggle)
    }
    
    @IBAction func qualityToggle(_ value: Bool) {
        userDefaults.set(value, forKey: settingsKeys.qualityToggle)
        if value == true {
            qualityToggle.setTitle("HD")
        } else {
            qualityToggle.setTitle("SD")
        }
    }
    
    @IBAction func proxyToggle(_ value: Bool) {
            userDefaults.set(value, forKey: settingsKeys.proxyContent)
    }
    
    @IBAction func resultLower() {
        if userDefaults.integer(forKey: settingsKeys.resultsCount) > 3 {
            userDefaults.set(userDefaults.value(forKey: settingsKeys.resultsCount) as! Int-1, forKey: settingsKeys.resultsCount)
            updateLabel()
        }
    }
    
    @IBAction func resultHigher() {
        if userDefaults.integer(forKey: settingsKeys.resultsCount) < 20 {
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
        
        // set the picker items up
        let pickerItems: [WKPickerItem] = videoTypes.map {
            let pickerItem = WKPickerItem()
            pickerItem.title = $0.capitalizingFirstLetter()
            return pickerItem
        }
        homeVideosPicker.setItems(pickerItems)
        
        // set all the properties of settings to match userdefaults
        homeVideosPicker.setSelectedItemIndex(Int(videoTypes.firstIndex(of: userDefaults.string(forKey: settingsKeys.homePageVideoType)!)!))
        thumbnailsToggle.setOn(userDefaults.bool(forKey: settingsKeys.thumbnailsToggle))
        audioOnlyToggle.setOn(userDefaults.bool(forKey: settingsKeys.audioOnlyToggle))
        qualityToggle.setOn(userDefaults.bool(forKey: settingsKeys.qualityToggle))
        proxyToggle.setOn(userDefaults.bool(forKey: settingsKeys.proxyContent))
        if userDefaults.bool(forKey: settingsKeys.qualityToggle) == true {qualityToggle.setTitle("HD")} else {qualityToggle.setTitle("SD")}
        
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
                var instanceItems: [WKPickerItem] = []
                let pickerItem = WKPickerItem()
                pickerItem.title = UserDefaults.standard.string(forKey: settingsKeys.instanceUrl)!
                instanceItems.append(pickerItem)
                self.instancePicker.setItems(instanceItems)
                self.instancePicker.setSelectedItemIndex(0)
                self.instanceStatus.setText("Unable to load instances")
                
            }
        }
        // Configure interface objects here.
    }
    
    @IBAction func selectInstance(_ value: Int) {
        self.instancePicker.setEnabled(false)
        self.instanceStatus.setTextColor(.lightGray)
        self.instanceStatus.setText("Loading...")
        AF.request("https://\(instances[value])/api/v1/search?q=e") { $0.timeoutInterval = 10 }.validate().responseJSON {resp in
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
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
