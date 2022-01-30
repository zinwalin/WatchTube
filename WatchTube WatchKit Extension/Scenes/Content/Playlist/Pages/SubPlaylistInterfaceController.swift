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
    var page = 1
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("Back")
        
        let data = context as! Dictionary<String,Any>
        list = data["list"] as! Array<Dictionary<String, Any>>
        page = data["page"] as! Int
        pageLabel.setText("Page (\(page))")
        // Configure interface objects here.
        
        setupTable()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func setupTable() {
        
        let constant = UserDefaults.standard.integer(forKey: settingsKeys.itemsCount)
        let page = 1
        let rangeLower = (page - 1) * constant
        var rangeHigher = rangeLower + (constant - 1)
        if list.count < rangeHigher {rangeHigher = list.count}
        
        subPlaylistTableRow.setNumberOfRows(rangeHigher, withRowType: "SubPlaylistRow")
        
        for i in rangeLower ..< rangeHigher {
            guard let row = subPlaylistTableRow.rowController(at: i) as? SubPlaylistTableRow else {
                continue
            }
            let video = list[i]
            
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
        
        subPlaylistTableRow.setHidden(false)
    }
}
