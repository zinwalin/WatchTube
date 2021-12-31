//
//  InterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by developer on 12/6/20.
//

import WatchKit
import Foundation
import Alamofire

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var loader: WKInterfaceImage!
    @IBOutlet weak var TrendingTableRow: WKInterfaceTable!
    @IBOutlet weak var internetLabel: WKInterfaceLabel!
    @IBOutlet weak var searchButton: WKInterfaceButton!
    @IBOutlet weak var tooltipLabel: WKInterfaceLabel!
    
    var videos: [Video]!
    override func awake(withContext context: Any?) {
        
        // if userdefaults don't exist (like when the app is freshly installed), set them all now.
        if UserDefaults.standard.value(forKey: settingsKeys.cacheToggle) == nil {
            UserDefaults.standard.set(true, forKey: settingsKeys.cacheToggle)
        }
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
        
        Video.getTrending() { videos in
            if videos.count == 0 {
                self.internetLabel.setHidden(false)
                self.searchButton.setEnabled(false)
                
            } else {
                self.internetLabel.setHidden(true)
                self.searchButton.setEnabled(true)
            }
            self.videos = videos
            self.setupTable()
            self.TrendingTableRow.setHidden(false)
            self.loader.setHidden(true)
            self.tooltipLabel.setHidden(false)
            self.loader.stopAnimating()
        }
    }
    
    override func willActivate() {
        
        loader.setImageNamed("loading")
        loader.startAnimatingWithImages(in: NSRange(location: 0, length: 6), duration: 0.75, repeatCount: 0)
        
        do {
            let cacheURL = URL(string: NSHomeDirectory()+"/Documents/cache")!
            if !FileManager.default.fileExists(atPath: cacheURL.path) {
                try FileManager.default.createDirectory(atPath: cacheURL.path, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {}
        
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    @IBAction func searchVideoButtonTapped() {
        
        var keywordsHistory = UserDefaults.standard.stringArray(forKey: preferencesKeys.keywordsHistory) ?? [String]()
        let lastTwentyKeywordsHistory = Array(keywordsHistory.suffix(20))
        self.presentTextInputController(withSuggestions: lastTwentyKeywordsHistory.reversed(), allowedInputMode: .plain) { (keywords) in
            if let keyword = keywords as? [String] {
                if keyword.count > 0 {
                    if let index = keywordsHistory.firstIndex(of: keyword[0]) {
                        keywordsHistory.remove(at: index)
                    }
                    keywordsHistory.append(keyword[0])
                    UserDefaults.standard.set(keywordsHistory, forKey: preferencesKeys.keywordsHistory)
                    let context = ["action": "search",
                                   "query": keyword[0]]
                    self.pushController(withName: "VideoListInterfaceController", context: context)
                }
            }
        }
    }
    
    func setupTable() {
        TrendingTableRow.setNumberOfRows(videos.count, withRowType: "TrendingRow")
        
        for i in 0 ..< videos.count {
            guard let row = TrendingTableRow.rowController(at: i) as? TrendingRow else {
                continue
            }
            row.trendingTitleLabel.setText(videos[i].title)
            row.videoId = videos[i].id
            row.trendingChannelLabel.setText(videos[i].channel)
            
            if UserDefaults.standard.value(forKey: settingsKeys.thumbnailsToggle) == nil {
                UserDefaults.standard.set(true, forKey: settingsKeys.thumbnailsToggle)
            }
            
            if UserDefaults.standard.bool(forKey: settingsKeys.thumbnailsToggle) == false {
                row.trendingThumbImg.setHidden(true)
            } else {
                row.trendingThumbImg.sd_setImage(with: URL(string: videos[i].img))
            }
            
            Global.cacheVideoInfo(id: videos[i].id)
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.pushController(withName: "NowPlayingInterfaceController", context: videos[rowIndex])
    }
}
