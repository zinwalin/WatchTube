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

var youtubedlServerURLBase = "https://" + Constants.downloadSrvInstance

class NowPlayingInterfaceController: WKInterfaceController {
    
    var infoViewed: Bool = false
    var isDownloading: Bool = false

    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var movie: WKInterfaceMovie!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var thumbnailBg: WKInterfaceImage!
    @IBOutlet var channelLabel: WKInterfaceLabel!
    @IBOutlet var movieLoading: WKInterfaceImage!
    
    var video: Video!
    
    @IBAction func infoScreenButton() {
        infoViewed=true
        self.pushController(withName: "InfoInterfaceController", context: self.video.id)
    }
    
    override func awake(withContext context: Any?) {
        
        if context != nil {
            self.video = context as? Video
        }
        
        if self.video != nil {
            self.titleLabel.setText(self.video.title)
            self.thumbnailBg.sd_setImage(with: URL(string: self.video.img))
            self.channelLabel.setText(self.video.channel)
        }
        
        movieLoading.setImageNamed("loading")
        movieLoading.startAnimatingWithImages(in: NSRange(location: 0, length: 6), duration: 0.75, repeatCount: 0)
        
        var dlType: String
        var fileType: String
        if UserDefaults.standard.bool(forKey: settingsKeys.audioOnlyToggle) == false {
            dlType = "download"
            fileType = "mp4"
        } else {
            dlType = "audio"
            fileType = "mp3"
        }
        
        let youtubedlServerURLDL = youtubedlServerURLBase + "/api/v2/\(dlType)?url=https://youtu.be"
        
        super.awake(withContext: context)

        let vidpath = youtubedlServerURLDL+"/"+self.video.id
        self.statusLabel.setText("Waiting for server...")
        isDownloading = true
        self.movie.setHidden(true)
        
        // dont forget about caching system
        let cachingSetting = UserDefaults.standard.bool(forKey: settingsKeys.cacheToggle)

        let destinationCached: DownloadRequest.Destination = { _, _ in
            let cachingFileURL = URL(fileURLWithPath: NSHomeDirectory()+"/Documents/cache").appendingPathComponent("\(self.video.id).\(fileType)")
            return (cachingFileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let destination: DownloadRequest.Destination = { _, _ in
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video.\(fileType)")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
                
        if cachingSetting == true {
            if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.video.id).\(fileType)") == true {
                self.movie.setMovieURL(URL(fileURLWithPath: NSHomeDirectory()+"/Documents/cache").appendingPathComponent("\(self.video.id).\(fileType)"))
                self.statusLabel.setText("Ready.")
                self.isDownloading = false
                self.showMovieFade(movie: self.movie)
                self.movieLoading.setHidden(true)
                self.movieLoading.stopAnimating()
            } else {
                AF.download(vidpath, to: destinationCached).response { response in
                    if response.value != nil {
                        self.movie.setMovieURL(response.value!!)
                        self.statusLabel.setText("Ready.")
                        self.isDownloading = false
                        self.showMovieFade(movie: self.movie)
                        self.movieLoading.setHidden(true)
                        self.movieLoading.stopAnimating()
                    }
                }.downloadProgress(closure: { (progress) in
                    let percent = Int((round(100 * progress.fractionCompleted) / 100) * 100)
                    self.statusLabel.setText("Downloading... \(percent)%")
                })
            }
        } else {
            AF.download(vidpath, to: destination).response { response in
                if response.value != nil {
                    self.movie.setMovieURL(response.value!!)
                    self.statusLabel.setText("Ready.")
                    self.isDownloading = false
                    self.showMovieFade(movie: self.movie)
                    self.movieLoading.setHidden(true)
                    self.movieLoading.stopAnimating()
                }
            }.downloadProgress(closure: { (progress) in
                let percent = Int((round(100 * progress.fractionCompleted) / 100) * 100)
                self.statusLabel.setText("Downloading... \(percent)%")
            })
        }
    }
    
    override func willActivate() {
        
        if UserDefaults.standard.bool(forKey: settingsKeys.cacheToggle) == true && infoViewed == true {
            if (!(FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.video.id).mp4") || FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.video.id).mp3"))) {
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
        animate(withDuration: 0.5) {
            movie.setHidden(false)
            movie.setAlpha(0.6)
        }
    }
}

