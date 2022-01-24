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
    var quality: String = ""

    @IBAction func cacheInfoScreenButton() {
        self.pushController(withName: "InfoInterfaceController", context: [
            "from":"CacheNowPlaying",
            "id": self.videoId,
            "quality":  quality
        ])
    }
    
    @IBAction func openChannel(_ sender: Any) {
        let udid = meta.getVideoInfo(id: videoId, key: "channelId") as! String
        if (meta.getChannelInfo(udid: udid, key: "name") as! String) == "???" {
            let download = WKAlertAction(title: "Load Now", style: .default) { meta.cacheChannelInfo(udid: udid)}
            let cancel = WKAlertAction(title: "Cancel", style: .cancel) {}
            presentAlert(withTitle: "Grab now?", message: "The data you requested is not on your device, get it now?", preferredStyle: .alert, actions: [download, cancel])
        } else {
            pushController(withName: "ChannelViewInterfaceController", context: meta.getVideoInfo(id: videoId, key: "channelId"))
        }
    }
    
    override func awake(withContext context: Any?) {
        cacheMovie.setHidden(true)
        super.awake(withContext: context)
        if context != nil {
            self.videoId = (context as? String)!
        }

        title = meta.getVideoInfo(id: videoId, key: "title") as! String
        img = meta.getVideoInfo(id: videoId, key: "thumbnail") as! String
        channel = meta.getVideoInfo(id: videoId, key: "channelName") as! String
        
        var fileType: String
        if UserDefaults.standard.bool(forKey: settingsKeys.audioOnlyToggle) == false {
            fileType = "mp4"
        } else {
            fileType = "m4a"
        }
        
        cacheThumbnailBg.sd_setImage(with: URL(string: img))
        cacheChannelLabel.setText(channel)
        
        if UserDefaults.standard.bool(forKey: settingsKeys.qualityToggle) == true {
            quality="hd"
        } else {
            quality="sd"
        } // set preferred quality
        
        if fileType == "mp4" && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/sd/\(self.videoId).mp4") == false) {
            fileType = "m4a"
            quality="sd"
            self.cacheStatusLabel.setText("Using m4a.")
            
        } else if fileType == "m4a" && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/sd/\(self.videoId).m4a") == false) {
            fileType = "mp4"
            quality="sd"
            self.cacheStatusLabel.setText("Using mp4.")
            
        } else if fileType == "mp4" && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/hd/\(self.videoId).mp4") == false) {
            fileType = "m4a"
            quality="hd"
            self.cacheStatusLabel.setText("Using m4a.")
            
        } else if fileType == "m4a" && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/hd/\(self.videoId).m4a") == false) {
            fileType = "mp4"
            quality="hd"
            self.cacheStatusLabel.setText("Using mp4.")
            
        } else if (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/sd/\(self.videoId).mp4") == false) && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/sd/\(self.videoId).m4a") == false) && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/hd/\(self.videoId).mp4") == false) && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/hd/\(self.videoId).m4a") == false) {
            self.cacheStatusLabel.setText("No cache data found.")
        }
                
        self.showMovieFade(movie: cacheMovie)
        self.cacheTitleLabel.setText(self.title)

        if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(quality)/\(self.videoId).\(fileType)") == true {
            self.cacheMovie.setMovieURL(URL(fileURLWithPath: NSHomeDirectory()+"/Documents/cache/\(quality)").appendingPathComponent("\(self.videoId).\(fileType)"))
            self.cacheStatusLabel.setText("Ready.")
        }
    }
    
    func showMovieFade(movie: WKInterfaceMovie!) {
        movie.setAlpha(0)
        animate(withDuration: 0.5) {
            movie.setHidden(false)
            movie.setAlpha(0.5)
        }
    }
}
