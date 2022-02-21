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
    @IBOutlet weak var tooltipLabel: WKInterfaceLabel!
    @IBOutlet weak var reloadButton: WKInterfaceButton!
    
    var videos: [Video]!
    override func awake(withContext context: Any?) {
        misc.defaultSettings() // set any missing setting values now to avoid issues
        reloadButton.setHidden(true)
        loader.setHidden(false)
        internetLabel.setHidden(true)
        loader.setImageNamed("loading") // animate spinner
        loader.startAnimatingWithImages(in: NSRange(location: 0, length: 6), duration: 0.75, repeatCount: 0)
        
        Video.getTrending() { videos in // get trending videos 
            if videos.count == 0 { // show that there are no videos on trending, also means no internet
                // wait for the day when youtube gets rid of trending, then you can change this :)
                self.internetLabel.setHidden(false)
                self.reloadButton.setHidden(false)
                self.loader.setHidden(true) // hide the spinner
                self.loader.stopAnimating() // save resources idk
                return
                //self.searchButton.setEnabled(false) // dont disable the search, internet might be working. sometimes internet is available but no trending data shows idk why. 
                // it seems to fail when you quickly quit and relaunch the app :uhh:
            } else {
                self.internetLabel.setHidden(true)
                //self.searchButton.setEnabled(true)
            }
            self.videos = videos
            self.setupTable() // add videos to the table
            self.TrendingTableRow.setHidden(false)
            self.loader.setHidden(true) // hide the spinner
            self.tooltipLabel.setHidden(false) // show the tiny text at the bottom
            self.loader.stopAnimating() // save resources idk
        }
    }

    @IBAction func reloadData() {
        awake(withContext: "")
    }
    
//    @IBAction func searchVideoButtonTapped() {
//        
//        var keywordsHistory = UserDefaults.standard.stringArray(forKey: preferencesKeys.keywordsHistory) ?? [String]()
//        let lastTwentyKeywordsHistory = Array(keywordsHistory.suffix(20))
//        self.presentTextInputController(withSuggestions: lastTwentyKeywordsHistory.reversed(), allowedInputMode: .plain) { (keywords) in
//            if let keyword = keywords as? [String] {
//                if keyword.count > 0 {
//                    if let index = keywordsHistory.firstIndex(of: keyword[0]) {
//                        keywordsHistory.remove(at: index)
//                    }
//                    keywordsHistory.append(keyword[0])
//                    UserDefaults.standard.set(keywordsHistory, forKey: preferencesKeys.keywordsHistory)
//                    self.pushController(withName: "VideoListInterfaceController", context: keyword[0])
//                }
//            }
//        }
//    }
    
    func setupTable() -> Void {
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
            
            meta.cacheVideoInfo(id: videos[i].id)
        }
    }
    
    override func didAppear() {
        super.didAppear()
        
        if UserDefaults.standard.bool(forKey: settingsKeys.firstTimeGuide) == false {
            let nope = WKAlertAction(title: "Nope", style: .default, handler: {self.presentAlert(withTitle: "Okay then", message: "You can show this again in settings.", preferredStyle: .alert, actions: [WKAlertAction(title: "Okay", style: .default, handler: {})])})
            let sure = WKAlertAction(title: "Sure", style: .default, handler: {
                self.presentController(withName: "FirstTimeInterfaceController", context: "")
            })
            UserDefaults.standard.setValue(true, forKey: settingsKeys.firstTimeGuide)
            presentAlert(withTitle: "Welcome!", message: "Thanks for downloading WatchTube! Would you like to go through the first time help guide?", preferredStyle: .sideBySideButtonsAlert, actions: [nope, sure])
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let video = videos[rowIndex]
        if (meta.getVideoInfo(id: video.id, key: "title") as! String) == "???" {
            let ok = WKAlertAction(title: "Okay", style: .default) {}
            presentAlert(withTitle: "Slow Down!", message: "We're still waiting for the data you requested. Wait just a second!", preferredStyle: .alert, actions: [ok])
        } else {
            self.pushController(withName: "NowPlayingInterfaceController", context: video)
        }
    }
}
