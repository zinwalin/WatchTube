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
    @State var srcUrl: String
    @State var subtitleText: String
    var body: some View {
        ZStack {
            VideoPlayer(player:AVPlayer(playerItem:AVPlayerItem(url: URL(string: srcUrl)!)))
                .scaledToFill()
                .cornerRadius(0)
                .overlay(alignment: .bottomLeading, content: {
                    Text(subtitleText)
                        .font(.system(size: 10, weight: .regular, design: .default))
                        .multilineTextAlignment(.center)
                        .lineLimit(6)
                        .allowsHitTesting(false)
                })
                
        }
    }
}

struct playerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            playerView(srcUrl: "https://invidious.osi.kr/latest_version?id=w7ZcS2vEzIw&itag=22", subtitleText: "Plasma is when stuff is so hot that the nuclei and electrons can separate and flow around freely,\nwhich creates a goo like substance.")
            playerView(srcUrl: "man", subtitleText: "i guess this is what subtitles will look like, cool.")
        }
    }
}
