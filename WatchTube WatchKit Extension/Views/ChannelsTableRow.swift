//
//  ChannelsTableRow.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 17/01/2022.
//

import Foundation
import WatchKit

class ChannelsRow: NSObject {
    
    @IBOutlet var channelTitleLabel: WKInterfaceLabel!
    @IBOutlet var channelThumbImg: WKInterfaceImage!
    var videoId: String!
}

