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
        VStack {
            Text(UserDefaults.standard.string(forKey: hls.title) ?? "Unknown title")
                .lineLimit(2)
                .font(.footnote)
            VideoPlayer(player:AVPlayer(playerItem:AVPlayerItem(url: URL(string: UserDefaults.standard.string(forKey: hls.url) ?? "https://invidious.osi.kr/latest_version?id=bYCUt4sPlKc&itag=22")!)))
                .scaledToFit()
            HStack {
                Button(action: {
                    // push to info view controller with id context
                }) {
                    Image(systemName: "info.circle")
                }
                Button(action: {
                    // push to channel view controller with udid context
                }) {
                    Text(UserDefaults.standard.string(forKey: hls.channel) ?? "Unknown author")
                }
            }
        }
    }
}
