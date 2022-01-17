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
        
        if let dictionary = context as? Dictionary<String, Any> {
            if let action = dictionary["action"] as? String {
                if action == "search" {
                    let keyword = dictionary["query"] as! String
                    Video.getSearchResults(keyword: keyword) { videos in
                        if videos.count == 0 {self.searchInternetLabel.setHidden(false)} else {self.searchInternetLabel.setHidden(true)}
                        self.videos = videos
                        self.setupTable()
                        self.videoTableRow.setHidden(false)
                        self.searchLoader.stopAnimating()
                        self.searchLoader.setHidden(true)
                    }
                }
            }
        }
    }
    
    func setupTable() {
        videoTableRow.setNumberOfRows(videos.count, withRowType: "VideoRow")
        
        for i in 0 ..< videos.count {
            guard let row = videoTableRow.rowController(at: i) as? VideoRow else {
                continue
            }
            let video = videos[i]
            var type = ""
            if video.id != "" {
                type = "video"
                row.videoGroup.setHidden(false)
                row.channelGroup.setHidden(true)
            } else if video.udid != "" {
                type = "channel"
                row.videoGroup.setHidden(true)
                row.channelGroup.setHidden(false)
            } else {
                // something has gone really wrong bruh
                continue
                
            }
            row.titleLabel.setText(video.title)
            row.videoId = video.id
            row.channelLabel.setText(video.channel)
            
            row.udid = video.udid
            row.channelTitle.setText(video.channel)

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
            
            switch type {
            case "video":
                meta.cacheVideoInfo(id: video.id)
            case "channel":
                meta.cacheChannelInfo(udid: video.udid)
            default:
                break
            }
        }
    }
        
    override func table(_ table: WKInterfaceTable, didSelectRowAt i: Int) {
        let video = self.videos[i]
        var type = ""
        if video.id != "" {
            type = "video"
        } else if video.udid != "" {
            type = "channel"
        }
        switch type {
        case "video":
            self.pushController(withName: "NowPlayingInterfaceController", context: video)
        case "channel":
            self.pushController(withName: "ChannelViewInterfaceController", context: video.udid)
        default:
            self.pushController(withName: "NowPlayingInterfaceController", context: video)
        }
    }
    
}
