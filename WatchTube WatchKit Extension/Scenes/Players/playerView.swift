//
//  playerView.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 10/02/2022.
//

import SwiftUI
import AVFoundation
import Foundation
import AVKit

struct playerView: View {
    var body: some View {
        VideoPlayer(player:AVPlayer(playerItem:AVPlayerItem(url: URL(string: UserDefaults.standard.string(forKey: "hlsStreamUrlContext") ?? "")!)))
        .scaledToFill()
    }
}

struct playerView_Previews: PreviewProvider {
    static var previews: some View {
        playerView()
    }
}
