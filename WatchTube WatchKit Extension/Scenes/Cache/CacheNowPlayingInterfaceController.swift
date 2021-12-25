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
    @IBOutlet weak var cacheThumbnailBg: WKInterfaceImage!
    
    var id: String = ""
    var title: String = ""
    var img: String = ""

    @IBAction func cacheInfoScreenButton() {
        self.pushController(withName: "InfoInterfaceController", context: self.id)
    }
    
    override func awake(withContext context: Any?) {
        cacheMovie.setHidden(true)
        super.awake(withContext: context)
        if context != nil {
            self.id = (context as? String)!
        }
        
        do {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dataFileURL = dir.appendingPathComponent("miscCache/"+id)
            
            let data = try String(contentsOf: dataFileURL, encoding: .utf8).components(separatedBy: "\n")
            // ok so data[0] is the video title and data[1] is image url
            title = data[0]
            img = data[1]
        }} catch {}
        
        var fileType: String
        if UserDefaults.standard.bool(forKey: settingsKeys.audioOnlyToggle) == false {
            fileType = "mp4"
        } else {
            fileType = "mp3"
        }
        
        cacheThumbnailBg.sd_setImage(with: URL(string: img))
        
        if fileType == "mp4" && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.id).mp4") == false) {
            fileType = "mp3"
            self.cacheStatusLabel.setText("mp4 not cached. Using mp3.")
        } else if fileType == "mp3" && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.id).mp3") == false) {
            fileType = "mp4"
            self.cacheStatusLabel.setText("mp3 not cached. Using mp4.")
        } else if ((FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.id).mp4") == false) && (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.id).mp3") == false)) {
            self.cacheStatusLabel.setText("No cache data found.")
        } else {
            self.cacheStatusLabel.setText("Ready.")
        }
                
        self.showMovieFade(movie: cacheMovie)
        self.cacheTitleLabel.setText(self.title)

        if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(self.id).\(fileType)") == true {
            self.cacheMovie.setMovieURL(URL(fileURLWithPath: NSHomeDirectory()+"/Documents/cache").appendingPathComponent("\(self.id).\(fileType)"))
        }
    }
    
    override func didAppear() {
        
        if UserDefaults.standard.bool(forKey: settingsKeys.cacheToggle) == true {
            if (!(FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(id).mp4") || FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(id).mp3"))) {pop()}
        }
        
        super.didAppear()
    }
    
    func showMovieFade(movie: WKInterfaceMovie!) {
        animate(withDuration: 0.5) {
            movie.setHidden(false)
            movie.setAlpha(0.6)
        }
    }
}
