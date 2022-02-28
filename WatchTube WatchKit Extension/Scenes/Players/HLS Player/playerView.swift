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
import Alamofire

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
    var subs: SubtitleSet!
    var subtitlesEnabled = UserDefaults.standard.bool(forKey: hls.captionsOn)
    var player = AVPlayer(url: URL(string: UserDefaults.standard.string(forKey: hls.url)!)!)
    var timeObserverToken: Any?
    var subtitleText = Subtitle.init(text: "WatchTube", beginning: 0, end: 10)
      
    init() {
        let errorSub = SubtitleSet.init(lang: UserDefaults.standard.string(forKey: hls.captionsLangCode) ?? "en", subtitles: [Subtitle.init(text: "Captions not available,\nan error occurred.", beginning: 0, end: 10)])
        //take data from url and parse it into subtitles
        let url = "https://\(UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? Constants.defaultInstance)/api/v1/captions/\(UserDefaults.standard.string(forKey: hls.videoId) ?? "idk")?lang=en"
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in guard let data = data, error == nil else
            {    // check for fundamental networking error
                self.subs = errorSub
                return
            }
            let result = String(data: data, encoding: .utf8) ?? ""
            if result.contains("WEBVTT") == false {
                self.subs = errorSub
                return
            }
            var subtitlesData = result.components(separatedBy: "\n\n")
            subtitlesData.removeLast()
            if subtitlesData.count == 0 {
                self.subs = errorSub
                return
            }
            let meta = String(describing: subtitlesData[0])
            let language:String = meta.description.components(separatedBy: "\n")[2].components(separatedBy: ": ")[1].description
            
            var array: [Subtitle] = []
            subtitlesData = subtitlesData.suffix(subtitlesData.count - 1)

            for subtitleItem in subtitlesData {
                // ok now we start doing more parsing of each subtitle
                let subMeta = subtitleItem.components(separatedBy: "\n")
                let rawTimestamp = subMeta[0]
                let subtext = subMeta.dropFirst().joined(separator: " ")
                
                let timeSplit = rawTimestamp.components(separatedBy: " --> ")
                var total: Double = 0
                //work out first timestamp in seconds
                var broken = timeSplit[0].split(separator: ":")
                total = total + (Double(broken[0]) ?? 0) * 3600 // get the hours and times it by 3600 to get it in seconds :D
                total = total + (Double(broken[1]) ?? 0) * 60 // same as above but for minutes
                total = total + (Double(broken[2]) ?? 0) // already in seconds and in decimal too.
                let beginning: Double = total
                
                total = 0
                broken = timeSplit[1].split(separator: ":")
                total = total + (Double(broken[0]) ?? 0) * 3600 // get the hours and times it by 3600 to get it in seconds :D
                total = total + (Double(broken[1]) ?? 0) * 60 // same as above but for minutes
                total = total + (Double(broken[2]) ?? 0) // already in seconds and in decimal too.
                let end: Double = total
                let finalSub = Subtitle.init(text: subtext, beginning: beginning, end: end)
                array.append(finalSub)
            }
            self.subs = SubtitleSet.init(lang: language, subtitles: array)
            
        }
        task.resume()
        
        let interval = CMTime(seconds: 0.2, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [self] time in
            let seconds: Double = CMTimeGetSeconds(time)
            objectWillChange.send()
            if subs != nil {
                for subtitle in subs.subtitles {
                    if (seconds >= subtitle.beginning) && (seconds <= subtitle.end) {
                        subtitleText = subtitle
                        break
                    } else {continue}
                }
            }
            
        }
    }
}

struct playerView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            VideoPlayer(player: viewModel.player)
                .onAppear { viewModel.player.play() }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(0)
                .overlay(alignment: .bottom, content: {
                    if (viewModel.subtitlesEnabled == true) {
                        if (viewModel.subtitleText.end <= viewModel.player.currentTime().seconds) {
                            // the text wont display, the subtitle isnt declared. do whatever here
                            
                        } else {
                            Text(viewModel.subtitleText.text)
                                .font(.system(size: 9))
                                .lineLimit(5)
                                .multilineTextAlignment(.center)
                                .background(Color(.displayP3, red: 0, green: 0, blue: 0, opacity: 0.4))
                                .cornerRadius(5)
                                .allowsHitTesting(false)
                        }
                    }
                })
                .onAppear {
                    viewModel.player.play()
                }
                .onDisappear {
                    viewModel.player = AVPlayer(url: URL(string: "https://google.com")!)
                }
        }
    }
}
