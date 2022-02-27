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

struct Subtitle {
    var text: String
    var beginning: Double
    var end: Double
}

struct SubtitleSet {
    var lang: String
    var subtitles: [Subtitle]
}

class ViewModel: ObservableObject {
    var subtitlesEnabled = UserDefaults.standard.bool(forKey: hls.captionsOn)
    var player = AVPlayer(url: URL(string: UserDefaults.standard.string(forKey: hls.url)!)!)
    var timeObserverToken: Any?
    var subtitleText = "Hi there"
      
    init() {
        let interval = CMTime(seconds: 2, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [self] time in
            // print(CMTimeGetSeconds(time))
            objectWillChange.send()
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            
            subtitleText = String((0..<20).map{ _ in letters.randomElement()! })
        }
    }
}

struct playerView: View {
    @StateObject var viewModel = ViewModel()
    
//    @State var subtitleText: String
    var body: some View {
        ZStack {
            VideoPlayer(player: viewModel.player)
                .onAppear { viewModel.player.play() }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(0)
                .overlay(alignment: .bottom, content: {
                    if (viewModel.subtitlesEnabled == true) {
                        Text(viewModel.subtitleText)
                            .font(.system(size: 9))
                            .lineLimit(5)
                            .multilineTextAlignment(.center)
                            .background(Color(red: 0.4, green: 0.4, blue: 0.4, opacity: 0.3))
                            .cornerRadius(5)
                            .allowsHitTesting(false)
                    }
                })
                .onAppear {
                    viewModel.player.play()
                }
        }
    }
}

struct playerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            playerView(srcUrl: "https://invidious.osi.kr/latest_version?id=w7ZcS2vEzIw&itag=22", subtitleText: "Plasma is when stuff is so hot that the nuclei and electrons can separate and flow around freely, which creates a goo like substance.")
            playerView()
        }
    }
}

