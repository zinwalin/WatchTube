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

var video: Video!

class NowPlayingInterfaceController: WKInterfaceController {
    
    var infoViewed: Bool = false
    var isDownloading: Bool = false
    var fileType: String = ""
    var streamUrl: String = ""

    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var movie: WKInterfaceMovie!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var thumbnailBg: WKInterfaceImage!
    @IBOutlet var channelLabel: WKInterfaceLabel!
    @IBOutlet var movieLoading: WKInterfaceImage!
    
    @IBAction func infoScreenButton() {
        infoViewed=true
        self.pushController(withName: "InfoInterfaceController", context: ["from":"NowPlaying", "id": video.id])
    }
    
    @IBAction func openChannel(_ sender: Any) {
        if (meta.getChannelInfo(udid: meta.getVideoInfo(id: video.id, key: "channelId") as! String, key: "name") as! String) == "???" {
            let ok = WKAlertAction(title: "Okay", style: .default) {}
            presentAlert(withTitle: "Slow Down!", message: "We can't get the data you requested. Wait just a second!", preferredStyle: .alert, actions: [ok])
        } else {
            pushController(withName: "ChannelViewInterfaceController", context: meta.getVideoInfo(id: video.id, key: "channelId"))
        }
    }
    
    override func awake(withContext context: Any?) {
        if context != nil {
            video = context as? Video
        }
        meta.cacheVideoInfo(id: video.id)
        
        if video != nil {
            self.titleLabel.setText(video.title)
            self.thumbnailBg.sd_setImage(with: URL(string: video.img))
            self.channelLabel.setText(video.channel)
        }
        
        var dlType: String
        if UserDefaults.standard.bool(forKey: settingsKeys.audioOnlyToggle) == false {
            dlType = "video"
            fileType = "mp4"
        } else {
            dlType = "audio"
            fileType = "m4a"
        }
                
        super.awake(withContext: context)

        let dataPath = "https://\(UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? "vid.puffyan.us")/api/v1/videos/\(video.id)?fields=formatStreams(url,container),adaptiveFormats(url,container,encoding,bitrate)"
        
        self.statusLabel.setText("Downloading data...")
        self.movieLoading.setImageNamed("loading")
        self.movieLoading.startAnimatingWithImages(in: NSRange(location: 0, length: 6), duration: 0.75, repeatCount: 0)
        self.movie.setHidden(true)
        
        meta.cacheChannelInfo(udid: meta.getVideoInfo(id: video.id, key: "channelId") as! String)
        
        if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(video.id).\(self.fileType)") == true {
            self.movie.setMovieURL(URL(fileURLWithPath: NSHomeDirectory()+"/Documents/cache").appendingPathComponent("\(video.id).\(self.fileType)"))
            self.statusLabel.setText("Ready.")
            self.isDownloading = false
            showMovieFade(movie: self.movie)
            self.movieLoading.setHidden(true)
            self.movieLoading.stopAnimating()
        } else {
            AF.request(dataPath).responseJSON { res in
                switch res.result {
                case .success(let data):
                    let videoDetails = data as! Dictionary<String, Any>
                    self.statusLabel.setText("Parsing data...")
                    self.isDownloading = true
                    
                    // Required variables in this scope
                    // - streamUrl (to set)
                    // - fileType (to set)
                    // - dlType (to use)
                    
                    // parse the video info for links. check dl type to set streamUrl to src of audio or video
                    
                    if (videoDetails["adaptiveFormats"] as! Array<Dictionary<String, Any>>).count == 0 || (videoDetails["formatStreams"] as! Array<Dictionary<String, Any>>).count == 0 {
                        self.statusLabel.setText("No streams found")
                        self.movieLoading.stopAnimating()
                        self.movieLoading.setImageNamed("error")
                        break
                    }
                    
                    print((videoDetails["adaptiveFormats"] as! Array<Dictionary<String, Any>>).count, (videoDetails["formatStreams"] as! Array<Dictionary<String, Any>>).count)
                    
                    if dlType == "video" {
                        let formatStreams = videoDetails["formatStreams"] as! Array<Dictionary<String, Any>>
                        let streamData = formatStreams[formatStreams.count - 1]
                        self.streamUrl = streamData["url"] as! String
                        self.fileType = "mp4"
                    } else if dlType == "audio" {
                        let adaptiveFormats = videoDetails["adaptiveFormats"] as! Array<Dictionary<String, Any>>
                        var aacFormats: Array<Dictionary<String, Any>> = []
                        for item in adaptiveFormats {
                            if item["encoding"] != nil {
                                if item["encoding"] as! String == "aac" {
                                    aacFormats.append(item)
                                }
                            }
                        }
                        print(aacFormats)
                        var highestBitrate: Int = 0
                        var format: Dictionary<String, Any> = [:]
                        if aacFormats.count != 1 {
                            for item in aacFormats {
                                if (item["bitrate"] as! NSString).integerValue > highestBitrate {
                                    highestBitrate = (item["bitrate"] as! NSString).integerValue
                                    format = item
                                }
                            }
                        } else {format = aacFormats[0]}
                        print(format)
                        self.streamUrl = format["url"] as! String
                    }
                    
                    if UserDefaults.standard.bool(forKey: settingsKeys.proxyContent) {
                        // modify streamURL to use instance proxying
                        let host = (URL(string: self.streamUrl)?.host)! as String
                        self.streamUrl = self.streamUrl.replacingOccurrences(of: host, with: UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? "vid.puffyan.us")
                    }
                            
                    // dont forget about caching system
                    let cachingSetting = UserDefaults.standard.bool(forKey: settingsKeys.cacheToggle)

                    let destinationCached: DownloadRequest.Destination = { _, _ in
                        let cachingFileURL = URL(fileURLWithPath: NSHomeDirectory()+"/Documents/cache").appendingPathComponent("\(video.id).\(self.fileType)")
                        return (cachingFileURL, [.removePreviousFile, .createIntermediateDirectories])
                    }
                    let destination: DownloadRequest.Destination = { _, _ in
                        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video.\(self.fileType)")
                        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                    }
                    
                    if cachingSetting == true {
                        AF.download(self.streamUrl, to: destinationCached).response { response in
                            if response.value != nil {
                                var totalSize = 0 as Int64
                                if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: NSHomeDirectory()+"/Documents/cache/\(video.id).\(self.fileType)") {
                                    if let bytes = fileAttributes[.size] as? Int64 {
                                        totalSize = totalSize+bytes
                                    }
                                }
                                
                                if totalSize == 0 {
                                    self.isDownloading = false
                                    self.statusLabel.setText("Error getting data")
                                    self.movieLoading.stopAnimating()
                                    self.movieLoading.setImageNamed("error")
                                    do {try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Documents/cache/\(video.id).\(self.fileType)")} catch {}
                                } else {
                                    self.movie.setMovieURL(response.value!!)
                                    self.statusLabel.setText("Ready.")
                                    self.isDownloading = false
                                    self.showMovieFade(movie: self.movie)
                                    self.movieLoading.setHidden(true)
                                    self.movieLoading.stopAnimating()
                                }
                            }
                        }.downloadProgress(closure: { (progress) in
                            let percent = round((progress.fractionCompleted*100) * 10) / 10.0
                            self.statusLabel.setText("Loading... \(percent)%")
                        })
                    } else {
                        AF.download(self.streamUrl, to: destination).response { response in
                            if response.value != nil {
                                var totalSize = 0 as Int64
                                if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: NSHomeDirectory()+"/tmp/video.\(self.fileType)") {
                                    if let bytes = fileAttributes[.size] as? Int64 {
                                        totalSize = totalSize+bytes
                                    }
                                }
                                
                                if totalSize == 0 {
                                    self.isDownloading = false
                                    self.statusLabel.setText("Error getting data")
                                    self.movieLoading.stopAnimating()
                                    self.movieLoading.setImageNamed("error")
                                } else {
                                    self.movie.setMovieURL(response.value!!)
                                    self.statusLabel.setText("Ready.")
                                    self.isDownloading = false
                                    self.showMovieFade(movie: self.movie)
                                    self.movieLoading.setHidden(true)
                                    self.movieLoading.stopAnimating()
                                }
                            }
                        }.downloadProgress(closure: { (progress) in
            //                let percent = Int((round(100 * progress.fractionCompleted) / 100) * 100)
                            let percent = round((progress.fractionCompleted*100) * 10) / 10.0
                            self.statusLabel.setText("Loading... \(percent)%")
                        })
                    }
                    
                case .failure(_):
                    self.statusLabel.setText("Error getting data")
                    self.movieLoading.stopAnimating()
                    self.movieLoading.setImageNamed("error")
                }
            }
        }
        
    }
    
    override func willActivate() {
        
        if UserDefaults.standard.bool(forKey: settingsKeys.cacheToggle) == true && infoViewed == true {
            if (!(FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(video.id).mp4") || FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(video.id).m4a"))) {
                if isDownloading {
                    infoViewed=false
                } else {
                    infoViewed=false
                    statusLabel.setText("File Deleted")
                    pop()
                }
            } else {
                infoViewed=false
            }
        }
        
        super.willActivate()
    }
    
    func showMovieFade(movie: WKInterfaceMovie!) {
        movie.setAlpha(0)
        animate(withDuration: 0.5) {
            movie.setHidden(false)
            movie.setAlpha(0.5)
        }
    }
}

