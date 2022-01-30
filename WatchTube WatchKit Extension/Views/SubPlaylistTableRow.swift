//
//  SubPlaylistTableRow.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 30/01/2022.
//

import WatchKit

class SubPlaylistTableRow: NSObject {
    @IBOutlet weak var SubPlaylistItemThumbnail: WKInterfaceImage!
    @IBOutlet weak var SubPlaylistItemTitle: WKInterfaceLabel!
    @IBOutlet weak var SubPlaylistItemChannel: WKInterfaceLabel!
    var videoId: String!
}
