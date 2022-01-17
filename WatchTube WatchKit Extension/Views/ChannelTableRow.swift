//
//  ChannelTableRow.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 16/01/2022.
//

import Foundation
import WatchKit


class ChannelRow: NSObject {
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var thumbImg: WKInterfaceImage!
    var videoId: String!
}

