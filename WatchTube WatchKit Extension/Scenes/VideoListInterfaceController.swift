//
//  VideoListInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by developer on 12/6/20.
//

import Foundation
import WatchKit
import SDWebImage

class VideoListInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var searchLoader: WKInterfaceImage!
    @IBOutlet var videoTableRow: WKInterfaceTable!
    @IBOutlet weak var searchInternetLabel: WKInterfaceLabel!
    
    var videos: [Video]!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        searchLoader.setImageNamed("loading")
        searchLoader.startAnimatingWithImages(in: NSRange(location: 0, length: 6), duration: 0.75, repeatCount: 0)
        
        if let dictionary = context as? Dictionary<String, Any> {
            if let action = dictionary["action"] as? String {
                if action == "search" {
                    let keyword = dictionary["query"] as! String
                    Video.getSearchResults(keyword: keyword) { videos in
                        if videos.count == 0 {self.searchInternetLabel.setHidden(false)} else {self.searchInternetLabel.setHidden(true)}
                        self.videos = videos
                        self.setupTable()
                        self.videoTableRow.setHidden(false)
                        self.searchLoader.stopAnimating()
                        self.searchLoader.setHidden(true)
                    }
                }
            }
        }
    }
    
    func setupTable() {
        videoTableRow.setNumberOfRows(videos.count, withRowType: "VideoRow")
        
        for i in 0 ..< videos.count {
            guard let row = videoTableRow.rowController(at: i) as? VideoRow else {
                continue
                }
            row.titleLabel.setText(videos[i].title)
            row.videoId = videos[i].id
            row.channelLabel.setText(videos[i].channel)
            
            if UserDefaults.standard.bool(forKey: settingsKeys.thumbnailsToggle) == false {
                row.thumbImg.setHidden(true)
            } else {
                row.thumbImg.sd_setImage(with: URL(string: videos[i].img))
            }
            
            meta.cacheVideoInfo(id: videos[i].id)
        }
    }
        
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.pushController(withName: "NowPlayingInterfaceController", context: self.videos[rowIndex])
    }
    
}
