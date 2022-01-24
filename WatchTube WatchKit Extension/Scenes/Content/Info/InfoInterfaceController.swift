//
//  CacheInfoInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 12/12/2021.
//

import WatchKit
import Foundation

class InfoInterfaceController: WKInterfaceController {
    @IBOutlet weak var viewsIcon: WKInterfaceImage!
    @IBOutlet weak var likesIcon: WKInterfaceImage!
    @IBOutlet weak var authorIcon: WKInterfaceImage!
    @IBOutlet weak var uploadIcon: WKInterfaceImage!
    
    
    @IBOutlet weak var viewsLabel: WKInterfaceLabel!
    @IBOutlet weak var likesLabel: WKInterfaceLabel!
    @IBOutlet weak var dateLabel: WKInterfaceLabel!
    @IBOutlet weak var authorLabel: WKInterfaceLabel!
    
    @IBOutlet weak var showDescriptionButton: WKInterfaceButton!
    @IBOutlet weak var InfoCacheDeleteButton: WKInterfaceButton!
    
    var videoId: String = ""
    var from: String = ""
    var udid: String = ""
    var quality: String = ""

    var videoDetails: Dictionary<String, Any> = [:]
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let data = context as! Dictionary<String, String>
        from = data["from"]!
        videoId = data["id"]!
        quality = data["quality"]!
        udid = meta.getVideoInfo(id: videoId, key: "channelId") as! String

        self.showDescriptionButton.setEnabled(false)
        self.likesLabel.setText("Loading Likes")
        self.viewsLabel.setText("Loading Views")
        self.dateLabel.setText("Loading Date")
        self.authorLabel.setText("Loading Channel")
        self.InfoCacheDeleteButton.setHidden(!(
            FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/sd/\(videoId).mp4") ||
            FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/sd/\(videoId).m4a") ||
            FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/hd/\(videoId).mp4") ||
            FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/hd/\(videoId).m4a")
        ))
        
        let likes = (meta.getVideoInfo(id: videoId, key: "likes") as! Int).abbreviated
        let views = (meta.getVideoInfo(id: videoId, key: "views") as! Int).abbreviated
        self.likesLabel.setText("\(likes) Likes")
        self.viewsLabel.setText("\(views) Views")
        self.dateLabel.setText("Uploaded \(String(describing: meta.getVideoInfo(id: videoId, key: "publishedDate")))")
        self.authorLabel.setText("\(String(describing: meta.getVideoInfo(id: videoId, key: "channelName")))")
        self.showDescriptionButton.setEnabled(true)
        

        
        // Configure interface objects here.
    }
    
    @IBAction func openChannel(_ sender: Any) {
        if (meta.getChannelInfo(udid: udid, key: "name") as! String) == "???" {
            let download = WKAlertAction(title: "Load Now", style: .default) { [self] in meta.cacheChannelInfo(udid: udid)}
            let cancel = WKAlertAction(title: "Cancel", style: .cancel) {}
            presentAlert(withTitle: "Grab now?", message: "The data you requested is not on your device, get it now?", preferredStyle: .alert, actions: [download, cancel])
        } else {
            pushController(withName: "ChannelViewInterfaceController", context: meta.getVideoInfo(id: videoId, key: "channelId"))
        }
    }
    
    @IBAction func showDescription() {
        self.pushController(withName: "SubInfoInterfaceController", context: meta.getVideoInfo(id: videoId, key: "description"))
    }
    
    @IBAction func infoDeleteCache() {
        do {
            if (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/sd/\(videoId).mp4")) {
                try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Documents/cache/sd/\(videoId).mp4")
            }
            if (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/sd/\(videoId).m4a")) {
                try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Documents/cache/sd/\(videoId).m4a")
            }
            if (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/hd/\(videoId).mp4")) {
                try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Documents/cache/hd/\(videoId).mp4")
            }
            if (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/hd/\(videoId).m4a")) {
                try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Documents/cache/hd/\(videoId).m4a")
            }
        } catch {}
        if from == "CacheNowPlaying" {
            UserDefaults.standard.set(true, forKey: miscKeys.pushToCacheContents)
            popToRootController()
        } else if from == "NowPlaying" {
            pop()
        }
    }
    
    @IBAction func randomise(_ sender: Any) {
        viewsIcon.setTintColor(.random())
        likesIcon.setTintColor(.random())
        authorIcon.setTintColor(.random())
        uploadIcon.setTintColor(.random())
    }

}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
