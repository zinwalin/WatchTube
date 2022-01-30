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
            
            row.videoGroup.setHidden(true)
            row.channelGroup.setHidden(true)
            row.playlistGroup.setHidden(true)

            switch type {
            case "video":
                row.videoGroup.setHidden(false)
            case "channel":
                row.channelGroup.setHidden(false)
            case "playlist":
                row.playlistGroup.setHidden(false)
            default:
                break
            }
            
            switch type {
            case "video":
                meta.cacheVideoInfo(id: video.id)
            case "channel":
                meta.cacheChannelInfo(udid: video.id)
            case "playlist":
                meta.cacheChannelInfo(udid: video.subs)
            default:
                break
            }
            
            row.playlistName.setText(video.title)
            row.videoId = video.id
            row.playlistChannel.setText(video.channel)
            
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
                case "playlist":
                    let thumbnails = video.img.components(separatedBy: "\n")
                    row.playlistIcon1.sd_setImage(with: URL(string: thumbnails[0]))
                    if thumbnails.count >= 2 {
                        row.playlistIcon2.sd_setImage(with: URL(string: thumbnails[1]))
                    }
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
                presentAlert(withTitle: "Slow Down!", message: "We're still waiting for the data you requested. Wait just a second!", preferredStyle: .alert, actions: [WKAlertAction(title: "Okay", style: .default) {}])
            } else {
                self.pushController(withName: "NowPlayingInterfaceController", context: video)
            }
        case "channel":
            if (meta.getChannelInfo(udid: video.id, key: "name") as! String) == "???" {
                presentAlert(withTitle: "Slow Down!", message: "We're still waiting for the data you requested. Wait just a second!", preferredStyle: .alert, actions: [WKAlertAction(title: "Okay", style: .default) {}])
            } else {
                self.pushController(withName: "ChannelViewInterfaceController", context: video.id)
            }
        case "playlist":
            if (meta.getChannelInfo(udid: video.subs, key: "name") as! String) == "???" {
                presentAlert(withTitle: "Slow Down!", message: "We're still waiting for the data you requested. Wait just a second!", preferredStyle: .alert, actions: [WKAlertAction(title: "Okay", style: .default) {}])
            } else {
                var dict: [String:String] = [:]
                dict["title"] = video.title
                dict["channelName"] = video.channel
                let thumbnails = video.img.components(separatedBy: "\n")
                dict["1"] = thumbnails[0]
                dict["2"] = thumbnails[1]
                dict["plid"] = video.id
                dict["udid"] = video.subs
                self.pushController(withName: "PlaylistInterfaceController", context: dict)
            }
        default:
            presentAlert(withTitle: "Malformed", message: "We don't know what just happened but it's bad. Please report this issue in our server or via TestFlight!", preferredStyle: .alert, actions: [WKAlertAction(title: "Okay", style: .default) {}])
        }
    }
    
}
