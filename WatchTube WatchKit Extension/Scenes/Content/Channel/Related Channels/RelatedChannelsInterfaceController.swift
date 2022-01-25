//
//  RelatedChannelsInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 17/01/2022.
//

import WatchKit
import Foundation
import Alamofire

class RelatedChannelsInterfaceController: WKInterfaceController {
    @IBOutlet weak var ChannelsTableRow: WKInterfaceTable!
    @IBOutlet weak var emptyLabel: WKInterfaceLabel!
    
    var channels: Array<Dictionary<String,String>> = []
    var udid = ""
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("Channels")
        udid = context as! String
        setupChannelsTable(udid: udid)
        
        // Configure interface objects here.
    }
    
    func setupChannelsTable(udid: String) {
        
        for channel in (meta.getChannelInfo(udid: udid, key: "relatedChannels") as! Array<Dictionary<String,String>>) {
            var dict: Dictionary<String,String> = [:]
            dict["udid"] = channel["udid"]
            dict["name"] = channel["name"]
            dict["thumbnail"] = meta.getChannelInfo(udid: dict["udid"]!, key: "thumbnail") as? String
            dict["subscribers"] = (meta.getChannelInfo(udid: dict["udid"]!, key: "subscribers") as! Double).abbreviated
            channels.append(dict)
        }
        if channels.isEmpty {
            ChannelsTableRow.setHidden(true)
            emptyLabel.setHidden(false)
        } else {
            ChannelsTableRow.setNumberOfRows(channels.count, withRowType: "ChannelsRow")
            
            for i in 0 ..< channels.count {
                guard let row = ChannelsTableRow.rowController(at: i) as? ChannelsRow else {
                    continue
                }
                let channel = channels[i]
                row.channelTitleLabel.setText(channel["name"])
                row.videoId = channel["udid"]
                row.channelSubsLabel.setText("\(channel["subscribers"]!) Subscribers")

                // ill add subscribers later
                
                if UserDefaults.standard.value(forKey: settingsKeys.thumbnailsToggle) == nil {
                    UserDefaults.standard.set(true, forKey: settingsKeys.thumbnailsToggle)
                }
                
                if UserDefaults.standard.bool(forKey: settingsKeys.thumbnailsToggle) == false {
                    row.channelThumbImg.setHidden(true)
                } else {
                    row.channelThumbImg.sd_setImage(with: URL(string: channel["thumbnail"]!))
                }
                
                meta.cacheChannelInfo(udid: channel["udid"]!)
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt i: Int) {
        let channel = channels[i]
        let tableUdid = channel["udid"]!
        if (meta.getChannelInfo(udid: tableUdid, key: "name") as! String) == "???" {
            let ok = WKAlertAction(title: "Okay", style: .default) {}
            presentAlert(withTitle: "Slow Down!", message: "We're still waiting for the data you requested. Wait just a second!", preferredStyle: .alert, actions: [ok])
        } else {
            pushController(withName: "ChannelViewInterfaceController", context: meta.getVideoInfo(id: tableUdid, key: "channelId"))
        }
    }
}
