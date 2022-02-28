//
//  NowPlayingInterfaceContoller.swift
//  WatchTube WatchKit Extension
//
//  Created by developer on 12/6/20.
//

import Foundation
import WatchKit
import Alamofire
import SDWebImage
import YouTubeKit

var video: Video!

class NowPlayingInterfaceController: WKInterfaceController {
    
    var fileType: String = ""
    var streamUrl: String = ""
    var quality: String = ""

    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var movie: WKInterfaceButton!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var thumbnailBg: WKInterfaceImage!
    @IBOutlet var channelLabel: WKInterfaceLabel!
    @IBOutlet var movieLoading: WKInterfaceImage!
    @IBOutlet var progressBar: WKInterfaceGroup!
    
    
    @IBAction func infoScreenButton() {
        self.pushController(withName: "InfoInterfaceController", context: ["from":"NowPlaying", "id": video.id, "quality": quality])
    }
    
    @IBAction func openChannel(_ sender: Any) {
        let udid = meta.getVideoInfo(id: video.id, key: "channelId") as! String
        if (meta.getChannelInfo(udid: udid, key: "name") as! String) == "???" {
            let ok = WKAlertAction(title: "Okay", style: .default) {}
            presentAlert(withTitle: "Slow Down!", message: "We're still waiting for the data you requested. Wait just a second!", preferredStyle: .alert, actions: [ok])
        } else {
            pushController(withName: "ChannelViewInterfaceController", context: meta.getVideoInfo(id: video.id, key: "channelId"))
        }
    }
    
    override func awake(withContext context: Any?) {
        Task {
            await main(context: context)
        }
    }
    
    @IBAction func pushToMovie() {
        UserDefaults.standard.set(streamUrl, forKey: hls.url)
        UserDefaults.standard.set(video.id, forKey: hls.videoId)
        pushController(withName: "HlsPlayer", context: streamUrl)
    }
    
    func showMovieFade(movie: WKInterfaceButton!) {
        movie.setAlpha(0)
        animate(withDuration: 0.5) {
            movie.setHidden(false)
            movie.setAlpha(0.5)
        }
    }
    
    func main(context: Any?) async {
        if context != nil {
            video = context as? Video
        }
        
        // cache metadata
        meta.cacheVideoInfo(id: video.id)
        meta.cacheChannelInfo(udid: meta.getVideoInfo(id: video.id, key: "channelId") as! String)
        // video meta should already be cached. if not, everything will probably break.
        
        progressBar.setHidden(true)
        progressBar.setRelativeWidth(0.0001, withAdjustment: 0)
        
        if video != nil {
            self.titleLabel.setText(video.title)
            self.thumbnailBg.sd_setImage(with: URL(string: video.img))
            self.channelLabel.setText(video.channel)
        } // set the thumbnail and labels
        
        var dlType: String // set filetypes as requested or needed
        if UserDefaults.standard.bool(forKey: settingsKeys.audioOnlyToggle) == false {
            dlType = "video"
            fileType = "mp4"
        } else {
            dlType = "audio"
            fileType = "m4a"
        }
        
        // true is hd
        if UserDefaults.standard.bool(forKey: settingsKeys.qualityToggle) == true {
            quality="hd"
        } else {
            quality="sd"
        }
        
        super.awake(withContext: context)
                
        self.statusLabel.setText("Getting stream data...")
        self.movieLoading.setImageNamed("loading")
        self.movieLoading.startAnimatingWithImages(in: NSRange(location: 0, length: 6), duration: 0.75, repeatCount: 0)
        self.movie.setHidden(true)
        progressBar.setHidden(false)
        
        do {
            // get streams
            let ytVideo = YouTube(videoID: video.id)
            let streams = try await ytVideo.streams
            var stream: YouTubeKit.Stream!
            
            //get the necessary stream
            if dlType == "video" {
                let videoStreams = streams.filter { $0.isProgressive && $0.subtype == "mp4" }
                if quality == "hd" {
                    stream = videoStreams.highestResolutionStream()
                } else if quality == "sd" {
                    stream = videoStreams.lowestResolutionStream()
                }
            } else if dlType == "audio" {
                let audioStreams = streams.filterAudioOnly()
                if quality == "hd" {
                    stream = audioStreams.filter { $0.subtype == "mp4" }
                    .highestAudioBitrateStream()
                } else if quality == "sd" {
                    stream = audioStreams.filter { $0.subtype == "mp4" }
                    .lowestAudioBitrateStream()
                }
            }
            // get the stream url, could be empty if there was no stream that met the criteria
            streamUrl = stream.url.absoluteString
            if streamUrl == "" {
                self.statusLabel.setText("Error getting data")
                self.movieLoading.stopAnimating()
                self.movieLoading.setImageNamed("error")
                self.progressBar.setHidden(true)
                return
            }
            
            // start finishing up
            
            statusLabel.setText("Ready.")
            showMovieFade(movie: movie)
            movieLoading.setHidden(true)
            movieLoading.stopAnimating()
            progressBar.setHidden(true)
            
        } catch {
            self.statusLabel.setText("Error getting data")
            self.movieLoading.stopAnimating()
            self.movieLoading.setImageNamed("error")
            self.progressBar.setHidden(true)
        }
            /// Old code here bc why not yk
//        let dataPath = "https://\(UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? Constants.defaultInstance)/api/v1/videos/\(video.id)?fields=formatStreams(url,container),adaptiveFormats(url,container,encoding,bitrate)"
//        AF.request(dataPath).responseJSON { res in
//            switch res.result {
//            case .success(let data):
//                let videoDetails = data as! Dictionary<String, Any>
//                self.statusLabel.setText("Parsing data...")
//                self.progressBar.setRelativeWidth(0.35, withAdjustment: 0)
//
//                // Required variables in this scope
//                // - streamUrl (to set)
//                // - fileType (to set)
//                // - dlType (to use)
//
//                // parse the video info for links. check dl type to set streamUrl to src of audio or video
//
//                if (videoDetails["adaptiveFormats"] as! Array<Dictionary<String, Any>>).count == 0 || (videoDetails["formatStreams"] as! Array<Dictionary<String, Any>>).count == 0 {
//                    self.statusLabel.setText("No streams found")
//                    self.movieLoading.stopAnimating()
//                    self.movieLoading.setImageNamed("error")
//                    self.progressBar.setHidden(true)
//                    break
//                }
//
//                if dlType == "video" {
//                    let formatStreams = videoDetails["formatStreams"] as! Array<Dictionary<String, Any>>
//                    if self.quality == "hd" {
//                        let streamData = formatStreams[formatStreams.count - 1]
//                        self.streamUrl = streamData["url"] as! String
//                        self.fileType = "mp4"
//                    } else if self.quality == "sd" {
//                        var streamData: Dictionary<String,String>
//                        if formatStreams.count >= 2 {
//                            streamData = formatStreams[1] as! Dictionary<String,String>
//                        } else {
//                            streamData = formatStreams[0] as! Dictionary<String,String>
//                        }
//                        self.streamUrl = streamData["url"]!
//                        self.fileType = "mp4"
//                    }
//                } else if dlType == "audio" {
//                    let adaptiveFormats = videoDetails["adaptiveFormats"] as! Array<Dictionary<String, Any>>
//                    var aacFormats: Array<Dictionary<String, Any>> = []
//                    for item in adaptiveFormats {
//                        if item["encoding"] != nil {
//                            if item["encoding"] as! String == "aac" {
//                                aacFormats.append(item)
//                            }
//                        }
//                    }
//
//                    var highestBitrate: Int = 0
//                    if self.quality == "sd" {highestBitrate = Int.max}
//                    var format: Dictionary<String, Any> = [:]
//                    if aacFormats.count != 1 {
//                        for item in aacFormats {
//                            if self.quality == "hd" {
//                                if (item["bitrate"] as! NSString).integerValue > highestBitrate {
//                                    highestBitrate = (item["bitrate"] as! NSString).integerValue
//                                    format = item
//                                }
//                            } else if self.quality == "sd" {
//                                if (item["bitrate"] as! NSString).integerValue < highestBitrate {
//                                    highestBitrate = (item["bitrate"] as! NSString).integerValue
//                                    format = item
//                                }
//                            }
//                        }
//                    } else {format = aacFormats[0]}
//                    self.streamUrl = format["url"] as! String
//                    self.fileType = "m4a"
//                }
//
//                if UserDefaults.standard.bool(forKey: settingsKeys.proxyContent) {
//                    // modify streamURL to use instance proxying
//                    let host = (URL(string: self.streamUrl)?.host)! as String
//                    self.streamUrl = self.streamUrl.replacingOccurrences(of: host, with: UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? Constants.defaultInstance)
//                }
//
//                self.progressBar.setRelativeWidth(0.65, withAdjustment: 0)
//                UserDefaults.standard.set(self.streamUrl, forKey: hls.url)
//
//                self.statusLabel.setText("Ready.")
//                self.showMovieFade(movie: self.movie)
//                self.movieLoading.setHidden(true)
//                self.movieLoading.stopAnimating()
//                self.progressBar.setHidden(true)
//
//            case .failure(_):
//                self.statusLabel.setText("Error getting data")
//                self.movieLoading.stopAnimating()
//                self.movieLoading.setImageNamed("error")
//                self.progressBar.setHidden(true)
//            }
//        }.downloadProgress { progress in
//            self.progressBar.setRelativeWidth(progress.fractionCompleted, withAdjustment: 0)
//        }
    }
}

