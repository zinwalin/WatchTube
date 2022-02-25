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
        let player = AVPlayer(url: (URL(string: srcUrl) ?? URL(string: "https://google.com")!))
        ZStack {
            VideoPlayer(player: player)
                .scaledToFill()
                .cornerRadius(0)
                .overlay(alignment: .bottom, content: {
                    Button("") {
                          let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                          subtitleText = String((0..<15).map{ _ in letters.randomElement()! })
                    }
                    Text(subtitleText)
                        .font(.system(size: 9))
                        .lineLimit(5)
                        .multilineTextAlignment(.center)
                        .background(Color(red: 0.4, green: 0.4, blue: 0.4, opacity: 0.3))
                        .cornerRadius(5)
                        .allowsHitTesting(false)
                })
        }
        .onChange(of: player.currentTime().epoch) { newValue in
            print(newValue)
            // why does this not work smh
        }
    }
}

struct playerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            playerView(srcUrl: "https://invidious.osi.kr/latest_version?id=w7ZcS2vEzIw&itag=22", subtitleText: "Plasma is when stuff is so hot that the nuclei and electrons can separate and flow around freely, which creates a goo like substance.")
            playerView(srcUrl: "https://invidious.osi.kr/latest_version?id=w7ZcS2vEzIw&itag=22", subtitleText: "egg")
        }
    }
}
