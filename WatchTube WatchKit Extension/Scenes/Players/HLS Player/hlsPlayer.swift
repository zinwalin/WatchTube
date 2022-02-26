//
//  hlsPlayer.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 10/02/2022.
//

import SwiftUI

class hlsPlayer: WKHostingController<playerView> {
    var streamUrl: String = ""
    override var body: playerView {
        return playerView(srcUrl: streamUrl)
    }
    override func awake(withContext context: Any?) {
        self.streamUrl = context as! String
        self.setNeedsBodyUpdate()
    }
}
