//
//  Misc.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 11/01/2022.
//

import Foundation
import WatchKit

class misc {
    class func defaultSettings() {
        // if userdefaults don't exist (like when the app is freshly installed), set them all now.
        if UserDefaults.standard.value(forKey: settingsKeys.thumbnailsToggle) == nil {
            UserDefaults.standard.set(true, forKey: settingsKeys.thumbnailsToggle)
        }
        if UserDefaults.standard.value(forKey: settingsKeys.audioOnlyToggle) == nil {
            UserDefaults.standard.set(false, forKey: settingsKeys.audioOnlyToggle)
        }
        if UserDefaults.standard.value(forKey: settingsKeys.resultsCount) == nil {
            UserDefaults.standard.set(10, forKey: settingsKeys.resultsCount)
        }
        if UserDefaults.standard.value(forKey: settingsKeys.itemsCount) == nil {
            UserDefaults.standard.set(12, forKey: settingsKeys.itemsCount)
        }
        if UserDefaults.standard.value(forKey: settingsKeys.homePageVideoType) == nil {
            UserDefaults.standard.set("default", forKey: settingsKeys.homePageVideoType)
        }
        if UserDefaults.standard.value(forKey: settingsKeys.instanceUrl) == nil {
            UserDefaults.standard.set(Constants.defaultInstance, forKey: settingsKeys.instanceUrl)
        }
        if UserDefaults.standard.value(forKey: settingsKeys.qualityToggle) == nil {
            UserDefaults.standard.set(true, forKey: settingsKeys.qualityToggle)
        }
        if UserDefaults.standard.value(forKey: settingsKeys.firstTimeGuide) == nil {
            UserDefaults.standard.set(false, forKey: settingsKeys.firstTimeGuide)
        }
        if UserDefaults.standard.value(forKey: hls.captionsLangCode) == nil {
            UserDefaults.standard.set("off", forKey: hls.captionsLangCode)
        }
        if UserDefaults.standard.value(forKey: settingsKeys.captionsSize) == nil {
            UserDefaults.standard.set(10, forKey: settingsKeys.captionsSize)
        }
    }
}

public extension Int {
    var abbreviated: String {
        let abbrev = "KMBTPE"
        return Array(abbrev).enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }
}
public extension Double {
    var abbreviated: String {
        let abbrev = "KMBTPE"
        return Array(abbrev).enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }
}

public extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

class subscriptions {
    class func getSubscriptions() -> Array<String> {
        if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/subscriptions.json") {
            if let array = NSArray(contentsOf: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/subscriptions.json")) {
                return array as? Array<String> ?? []
            } else {
                NSArray(array: []).write(to: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/subscriptions.json"), atomically: true)
                return []
            }
        } else {
            NSArray(array: []).write(to: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/subscriptions.json"), atomically: true)
            return []
        }
    }
    
    class func unsubscribe(udid: String) {
        if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/subscriptions.json") == false {return}
        if let array = NSArray(contentsOf: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/subscriptions.json")) {
            var mutable = array as! Array<String>
            while mutable.contains(udid) {
                let index = mutable.firstIndex(of: udid)
                mutable.remove(at: index!)
            }
            NSArray(array: mutable).write(to: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/subscriptions.json"), atomically: true)
        }
    }
    
    class func subscribe(udid: String) {
        if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/subscriptions.json") == false {
            NSArray(array: []).write(to: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/subscriptions.json"), atomically: true)
        }
        if let array = NSArray(contentsOf: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/subscriptions.json")) {
            var mutable = array as! Array<String>
            if mutable.contains(udid) {return} else {
                mutable.append(udid)
            }
            NSArray(array: mutable).write(to: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/subscriptions.json"), atomically: true)
        }
    }
}

class liked {
    class func getLikes() -> Array<String> {
        if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/likes.json") {
            if let array = NSArray(contentsOf: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/likes.json")) {
                return array as? Array<String> ?? []
            } else {
                NSArray(array: []).write(to: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/likes.json"), atomically: true)
                return []
            }
        } else {
            NSArray(array: []).write(to: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/likes.json"), atomically: true)
            return []
        }
    }
    
    class func unlike(id: String) {
        if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/likes.json") == false {return}
        if let array = NSArray(contentsOf: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/likes.json")) {
            var mutable = array as! Array<String>
            while mutable.contains(id) {
                let index = mutable.firstIndex(of: id)
                mutable.remove(at: index!)
            }
            NSArray(array: mutable).write(to: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/likes.json"), atomically: true)
        }
    }
    
    class func like(id: String) {
        if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/likes.json") == false {
            NSArray(array: []).write(to: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/likes.json"), atomically: true)
        }
        if let array = NSArray(contentsOf: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/likes.json")) {
            var mutable = array as! Array<String>
            if mutable.contains(id) {return} else {
                mutable.append(id)
            }
            NSArray(array: mutable).write(to: URL(fileURLWithPath: NSHomeDirectory()+"/Documents/likes.json"), atomically: true)
        }
    }
}
