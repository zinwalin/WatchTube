//
//  SubPlaylistInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 30/01/2022.
//

import WatchKit
import Foundation

class SubPlaylistInterfaceController: WKInterfaceController {
    @IBOutlet weak var prevButton: WKInterfaceButton!
    @IBOutlet weak var nextButton: WKInterfaceButton!
    @IBOutlet weak var pageLabel: WKInterfaceLabel!
    @IBOutlet weak var subPlaylistTableRow: WKInterfaceTable!
    
    var list: Array<Dictionary<String,Any>> = []
    var page = 0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("Back")
        
        let data = context as! Dictionary<String,Any>
        list = data["list"] as! Array<Dictionary<String, Any>>
        page = data["page"] as! Int
        pageLabel.setText("Page \(page)")
        // Configure interface objects here.
        
        setupTable()
    }
    @IBAction func nextPage() {
        let dict: [String : Any] = [
            "page": page + 1,
            "list": list
        ]
        pushController(withName: "SubPlaylistInterfaceController", context: dict)
    }
    @IBAction func prevPage() {
        pop()
    }
    
    func setupTable() {
        
        let constant = UserDefaults.standard.integer(forKey: settingsKeys.itemsCount)
        let rangeLower = (page - 1) * constant
        var rangeHigher = rangeLower + (constant - 1)
        if list.count < rangeHigher {
            rangeHigher = list.count
        }
        
        subPlaylistTableRow.setNumberOfRows((rangeHigher - rangeLower) + 1, withRowType: "SubPlaylistRow")
        
        for index in rangeLower ..< rangeHigher + 1 {
            let i = index - rangeLower
            guard let row = subPlaylistTableRow.rowController(at: i) as? SubPlaylistTableRow else {
                continue
            }
            let video = list[index]
            
            meta.cacheVideoInfo(id: video["videoId"] as! String)
            
            row.SubPlaylistItemTitle.setText(video["title"] as? String)
            row.videoId = video["videoId"] as? String
            row.SubPlaylistItemChannel.setText(video["author"] as? String)

            let thumbs = video["videoThumbnails"] as! Array<Dictionary<String,Any>>
            let url = thumbs[0]["url"] as! String
            
            if UserDefaults.standard.bool(forKey: settingsKeys.thumbnailsToggle) == false {
                row.SubPlaylistItemThumbnail.setHidden(true)
            } else {
                row.SubPlaylistItemThumbnail.sd_setImage(with: URL(string: url))
            }
        }
        
        if list.count <= rangeHigher + 1 {
            nextButton.setEnabled(false)
            nextButton.setAlpha(0.55)
        }
        
        subPlaylistTableRow.setHidden(false)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt i: Int) {
        let constant = UserDefaults.standard.integer(forKey: settingsKeys.itemsCount)
        let rangeLower = (page - 1) * constant
        
        let item = list[i + rangeLower]
        let id = item["videoId"] as! String
        let title = item["title"] as! String
        let thumbs = item["videoThumbnails"] as! Array<Dictionary<String,Any>>
        let img = thumbs[0]["url"] as! String
        let channel = item["author"] as! String
        let type = "video"
        let vid = Video.init(id: id, title: title, img: img, channel: channel, subs: "", type: type)
        pushController(withName: "NowPlayingInterfaceController", context: vid)
    }
}
