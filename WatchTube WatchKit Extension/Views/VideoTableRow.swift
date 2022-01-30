//
//  VideoTableRow.swift
//  WatchTube WatchKit Extension
//
//  Created by developer on 12/6/20.
//

import Foundation
import WatchKit

class VideoRow: NSObject {
    var videoId: String!
    @IBOutlet var channelLabel: WKInterfaceLabel!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var thumbImg: WKInterfaceImage!
    @IBOutlet weak var channelTitle: WKInterfaceLabel!
    @IBOutlet weak var channelImg: WKInterfaceImage!
    @IBOutlet weak var videoGroup: WKInterfaceGroup!
    @IBOutlet weak var channelGroup: WKInterfaceGroup!
    @IBOutlet weak var playlistGroup: WKInterfaceGroup!
    @IBOutlet weak var subscribersLabel: WKInterfaceLabel!
    @IBOutlet weak var playlistIcon1: WKInterfaceImage!
    @IBOutlet weak var playlistIcon2: WKInterfaceImage!
    @IBOutlet weak var playlistName: WKInterfaceLabel!
    @IBOutlet weak var playlistChannel: WKInterfaceLabel!
}
