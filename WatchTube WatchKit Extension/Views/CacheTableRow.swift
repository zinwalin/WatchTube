//
//  CacheTableRow.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 09/12/2021.
//

import WatchKit
import Foundation

class CacheTableRow: NSObject {
    @IBOutlet var cacheThumbImage: WKInterfaceImage!
    @IBOutlet var cacheTitleLabel: WKInterfaceLabel!
    @IBOutlet var cacheFilesize: WKInterfaceLabel!
    @IBOutlet var cacheChannelLabel: WKInterfaceLabel!
    var videoId: String!
}
