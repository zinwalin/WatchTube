//
//  ChannelDetailsInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 17/01/2022.
//

import WatchKit
import Foundation


class ChannelDetailsInterfaceController: WKInterfaceController {
    @IBOutlet weak var channelDescription: WKInterfaceLabel!
    @IBOutlet weak var viewsLabel: WKInterfaceLabel!
    @IBOutlet weak var joinedLabel: WKInterfaceLabel!
    @IBOutlet weak var subsLabel: WKInterfaceLabel!
    
    @IBOutlet weak var bannerImage: WKInterfaceImage!
    @IBOutlet weak var channelImage: WKInterfaceImage!
    @IBOutlet weak var channelLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let udid = context as! String
        
        let descript = meta.getChannelInfo(udid: udid, key: "description") as! String
        let views = (meta.getChannelInfo(udid: udid, key: "views") as! Double).abbreviated
        let subs = (meta.getChannelInfo(udid: udid, key: "subscribers") as! Double).abbreviated
        let joined = meta.getChannelInfo(udid: udid, key: "joined") as! String
        channelDescription.setText(descript)
        setTitle("Details")
        
        viewsLabel.setText("\(views) views")
        subsLabel.setText("\(subs) subscribers")
        joinedLabel.setText("Joined \(joined)")
        
        let banner = meta.getChannelInfo(udid: udid, key: "banner") as! String
        let thumbnail = meta.getChannelInfo(udid: udid, key: "thumbnail") as! String
        let channelName = meta.getChannelInfo(udid: udid, key: "name") as! String
        
        bannerImage.sd_setImage(with: URL(string: banner))
        channelImage.sd_setImage(with: URL(string: thumbnail))
        channelLabel.setText(channelName)
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
