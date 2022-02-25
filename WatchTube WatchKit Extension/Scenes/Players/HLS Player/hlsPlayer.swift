//
//  hlsPlayer.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 10/02/2022.
//

import SwiftUI

class hlsPlayer: WKHostingController<playerView> {
    override var body: playerView {
        return playerView(srcUrl: UserDefaults.standard.string(forKey: hls.url) ?? "", subtitleText: "hi®")
    }
}
