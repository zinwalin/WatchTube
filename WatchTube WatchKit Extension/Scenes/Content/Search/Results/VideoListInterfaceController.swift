//
//  VideoListInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by developer on 12/6/20.
//

import Foundation
import WatchKit
import SDWebImage

class VideoListInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var searchLoader: WKInterfaceImage!
    @IBOutlet var videoTableRow: WKInterfaceTable!
    @IBOutlet weak var searchInternetLabel: WKInterfaceLabel!
    
    var videos: [Video]!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        searchLoader.setImageNamed("loading")
        searchLoader.startAnimatingWithImages(in: NSRange(location: 0, length: 6), duration: 0.75, repeatCount: 0)
        
        let keyword = context as! String
        Video.getSearchResults(keyword: keyword) { videos in
            if videos.count == 0 {self.searchInternetLabel.setHidden(false)} else {self.searchInternetLabel.setHidden(true)}
            self.videos = videos
            self.setupTable()
            self.videoTableRow.setHidden(false)
            self.searchLoader.stopAnimating()
            self.searchLoader.setHidden(true)
        }
    }
    
    func setupTable() {
        
        videoTableRow.setHidden(false)
        videoTableRow.setNumberOfRows(videos.count, withRowType: "VideoRow")
        
        for i in 0 ..< videos.count {
            guard let row = videoTableRow.rowController(at: i) as? VideoRow else {
                continue
            }
            let video = videos[i]
            let type = video.type
            if type == "video" {
                row.videoGroup.setHidden(false)
                row.channelGroup.setHidden(true)
            } else if type == "channel" {
                row.videoGroup.setHidden(true)
                row.channelGroup.setHidden(false)
            } else {
                // something has gone really wrong bruh
                continue
            }
            
            switch type {
            case "video":
                meta.cacheVideoInfo(id: video.id)
            case "channel":
                meta.cacheChannelInfo(udid: video.id)
            default:
                break
            }
            
            row.titleLabel.setText(video.title)
            row.videoId = video.id
            row.channelLabel.setText(video.channel)
            
            row.udid = video.id
            row.channelTitle.setText(video.channel)
            row.subscribersLabel.setText("\(video.subs) Subscribers")

            if UserDefaults.standard.bool(forKey: settingsKeys.thumbnailsToggle) == false {
                row.thumbImg.setHidden(true)
                row.channelImg.setHidden(true)
            } else {
                switch type {
                case "video":
                    row.thumbImg.sd_setImage(with: URL(string: video.img))
                case "channel":
                    row.channelImg.sd_setImage(with: URL(string: video.img))
                default:
                    break
                }
            }
        }
        
        videoTableRow.setHidden(false)
    }
        
    override func table(_ table: WKInterfaceTable, didSelectRowAt i: Int) {
        let video = self.videos[i]
        let type = video.type

        switch type {
        case "video":
            if (meta.getVideoInfo(id: video.id, key: "title") as! String) == "???" {
                let ok = WKAlertAction(title: "Okay", style: .default) {}
                presentAlert(withTitle: "Slow Down!", message: "We can't get the data you requested. Wait just a second!", preferredStyle: .alert, actions: [ok])
            } else {
                self.pushController(withName: "NowPlayingInterfaceController", context: video)
            }
        case "channel":
            if (meta.getChannelInfo(udid: video.id, key: "name") as! String) == "???" {
                let ok = WKAlertAction(title: "Okay", style: .default) {}
                presentAlert(withTitle: "Slow Down!", message: "We can't get the data you requested. Wait just a second!", preferredStyle: .alert, actions: [ok])
            } else {
                self.pushController(withName: "ChannelViewInterfaceController", context: video.id)
            }
        case "playlist":
            print("egg")
        default:
            let ok = WKAlertAction(title: "Okay", style: .default) {}
            presentAlert(withTitle: "Malformed", message: "We don't know what just happened but it's bad. Please report this issue in our server or via TestFlight!", preferredStyle: .alert, actions: [ok])
        }
    }
    
}
