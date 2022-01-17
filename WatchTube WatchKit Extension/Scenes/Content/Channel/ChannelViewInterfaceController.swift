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
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let udid = context as? String ?? "UCYzPXprvl5Y-Sf0g4vX-m6g"
        
        let banner = meta.getChannelInfo(udid: udid, key: "banner") as! String
        let thumbnail = meta.getChannelInfo(udid: udid, key: "thumbnail") as! String
        let channel = meta.getChannelInfo(udid: udid, key: "name") as! String
        
        bannerImage.sd_setImage(with: URL(string: banner))
        channelImage.sd_setImage(with: URL(string: thumbnail))
        channelLabel.setText(channel)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
