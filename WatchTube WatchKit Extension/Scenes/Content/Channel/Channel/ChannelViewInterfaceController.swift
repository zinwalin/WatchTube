//
//  ChannelViewInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 16/01/2022.
//

import WatchKit
import Foundation
import SDWebImage

class ChannelViewInterfaceController: WKInterfaceController {
    @IBOutlet weak var channelLabel: WKInterfaceLabel!
    @IBOutlet weak var bannerImage: WKInterfaceImage!
    @IBOutlet weak var channelImage: WKInterfaceImage!
    @IBOutlet weak var ChannelTableRow: WKInterfaceTable!
    var videos: [Video] = []
    var channels: Array<Dictionary<String,String>> = []
    var udid = ""

    override func awake(withContext context: Any?) {
        setTitle("Channel")
        super.awake(withContext: context)
        udid = context as! String
        
        let banner = meta.getChannelInfo(udid: udid, key: "banner") as! String
        let thumbnail = meta.getChannelInfo(udid: udid, key: "thumbnail") as! String
        let channelName = meta.getChannelInfo(udid: udid, key: "name") as! String
        
        bannerImage.sd_setImage(with: URL(string: banner))
        channelImage.sd_setImage(with: URL(string: thumbnail))
        channelLabel.setText(channelName)
        
        let videosArray = meta.getChannelInfo(udid: udid, key: "videos") as! Array<Dictionary<String,Any>>
        for (i, vid) in videosArray.enumerated() {
            if i >= UserDefaults.standard.integer(forKey: settingsKeys.itemsCount) {break}
            let id = vid["videoId"] as! String
            let title = vid["title"] as! String
            let img = (vid["videoThumbnails"] as! Array<Dictionary<String,Any>>)[0]["url"] as! String
            let channel = vid["author"] as! String
            let final = Video(id: id, title: title, img: img, channel: channel, subs: "", type: "video")
            videos.append(final)
            meta.cacheVideoInfo(id: id)
        }
        setupTable()
        ChannelTableRow.setHidden(false)
        // Configure interface objects here.
        
        for channel in (meta.getChannelInfo(udid: udid, key: "relatedChannels") as! Array<Dictionary<String,String>>) {
            meta.cacheChannelInfo(udid: channel["udid"]!)
        }
    }

    func setupTable() {
        ChannelTableRow.setNumberOfRows(videos.count, withRowType: "ChannelVideoRow")
        
        for i in 0 ..< videos.count {
            guard let row = ChannelTableRow.rowController(at: i) as? ChannelVideoRow else {
                continue
            }
            let vid = videos[i]
            row.channelVideoTitleLabel.setText(vid.title)
            row.videoId = vid.id
            
            if UserDefaults.standard.value(forKey: settingsKeys.thumbnailsToggle) == nil {
                UserDefaults.standard.set(true, forKey: settingsKeys.thumbnailsToggle)
            }
            
            if UserDefaults.standard.bool(forKey: settingsKeys.thumbnailsToggle) == false {
                row.channelVideoThumbImg.setHidden(true)
            } else {
                row.channelVideoThumbImg.sd_setImage(with: URL(string: vid.img))
            }
            
            meta.cacheVideoInfo(id: vid.id)
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt i: Int) {
        pushController(withName: "NowPlayingInterfaceController", context: videos[i])
    }
    
    @IBAction func Details() {
        if meta.getChannelInfo(udid: udid, key: "name") as! String == "???" {
            let ok = WKAlertAction(title: "Okay", style: .default) {}
            presentAlert(withTitle: "Slow Down!", message: "We can't get the data you requested. Wait just a second!", preferredStyle: .alert, actions: [ok])
        } else {
            pushController(withName: "ChannelDetailsInterfaceController", context: udid)
        }
    }
    
    @IBAction func RelatedChannels() {
        if meta.getChannelInfo(udid: udid, key: "name") as! String == "???" {
            let ok = WKAlertAction(title: "Okay", style: .default) {}
            presentAlert(withTitle: "Slow Down!", message: "We can't get the data you requested. Wait just a second!", preferredStyle: .alert, actions: [ok])
        } else {
            pushController(withName: "RelatedChannelsInterfaceController", context: udid)
        }
    }
    
    @IBAction func showProfileImage(_ sender: Any) {
        if udid != "" {
            presentController(withName: "ProfileViewInterfaceController", context: meta.getChannelInfo(udid: udid, key: "thumbnail"))
        }
    }
}
