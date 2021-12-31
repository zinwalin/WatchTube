//
//  CacheNowPlayingInterfaceContoller.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 10/12/21.
//

import Foundation
import WatchKit
import Alamofire
import SDWebImage

// bruh all this is just mega stripped down from NowPlayingInterfaceContoller.swift lol
// i removed all the unneeded checks and stuff

class CacheNowPlayingInterfaceController: WKInterfaceController {

    @IBOutlet weak var cacheTitleLabel: WKInterfaceLabel!
    @IBOutlet weak var cacheMovie: WKInterfaceMovie!
    @IBOutlet weak var cacheStatusLabel: WKInterfaceLabel!
    @IBOutlet weak var cacheChannelLabel: WKInterfaceLabel!
    @IBOutlet weak var cacheThumbnailBg: WKInterfaceImage!
    
    var videoId: String = ""
    var title: String = ""
    var img: String = ""
    var channel: String = ""

    @IBAction func cacheInfoScreenButton() {
        self.pushController(withName: "InfoInterfaceController", context: self.videoId)
    }
    
    override func awake(withContext context: Any?) {
        cacheMovie.setHidden(true)
        super.awake(withContext: context)
        if context != nil {
            self.videoId = (context as? String)!
        }

        title = Global.getVideoInfo(id: videoId, key: "title") as! String
        img = Global.getVideoInfo(id: videoId, key: "thumbnail") as! String
        channel = Global.getVideoInfo(id: videoId, key: "channelName") as! String

        
        var fileType: String
        if UserDefaults.standard.bool(forKey: settingsKeys.audioOnlyToggle) == false {
            fileType = "mp4"
        } else {
            fileType = "mp3"
        }
        
        cacheThumbnailBg.sd_setImage(with: URL(string: img))
        cacheChannelLabel.setText(channel)
        
        
        if fileType == "mp4" && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.videoId).mp4") == false) {
            fileType = "mp3"
            self.cacheStatusLabel.setText("Using mp3.")
        } else if fileType == "mp3" && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.videoId).mp3") == false) {
            fileType = "mp4"
            self.cacheStatusLabel.setText("Using mp4.")
        } else if ((FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.videoId).mp4") == false) && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.videoId).mp3") == false)) {
            self.cacheStatusLabel.setText("No cache data found.")
        } else {
            self.cacheStatusLabel.setText("Ready.")
        }
                
        self.showMovieFade(movie: cacheMovie)
        self.cacheTitleLabel.setText(self.title)

        if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.videoId).\(fileType)") == true {
            self.cacheMovie.setMovieURL(URL(fileURLWithPath: NSHomeDirectory()+"/Documents/cache").appendingPathComponent("\(self.videoId).\(fileType)"))
        }
    }
    
    override func didAppear() {
        
        if UserDefaults.standard.bool(forKey: settingsKeys.cacheToggle) == true {
            if (!(FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(videoId).mp4") || FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(videoId).mp3"))) {pop()}
        }
        
        super.didAppear()
    }
    
    func showMovieFade(movie: WKInterfaceMovie!) {
        movie.setAlpha(0)
        animate(withDuration: 0.5) {
            movie.setHidden(false)
            movie.setAlpha(0.5)
        }
    }
}
