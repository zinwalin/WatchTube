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
        VideoPlayer(player:AVPlayer(url: URL(string: UserDefaults.standard.string(forKey: hls.url) ?? "https://invidious.osi.kr/latest_version?id=bYCUt4sPlKc&itag=22")!))
            .scaledToFill().cornerRadius(0)
    }
}
