//
//  PlaylistInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 29/01/2022.
//

import WatchKit
import Foundation
import Alamofire

class PlaylistInterfaceController: WKInterfaceController {
    @IBOutlet weak var bannerImage1: WKInterfaceImage!
    @IBOutlet weak var bannerImage2: WKInterfaceImage!
    @IBOutlet weak var bannerImage3: WKInterfaceImage!

    @IBOutlet weak var plTitleLabel: WKInterfaceLabel!
    @IBOutlet weak var plChannelName: WKInterfaceLabel!
    @IBOutlet weak var plChannelImg: WKInterfaceImage!
    
    @IBOutlet weak var separatorTotalLabel: WKInterfaceLabel!
    @IBOutlet weak var pageControl: WKInterfaceGroup!
    
    @IBOutlet weak var playlistTableRow: WKInterfaceTable!
    
    var list: Array<Dictionary<String,Any>> = []
    var udid = ""
    
    override func awake(withContext context: Any?) {
        
        super.awake(withContext: context)
        let plData = context as! Dictionary<String,Any>
        let channelName = plData["channelName"] as! String
        let title = plData["title"] as! String
        let plid = plData["plid"] as! String
        udid = plData["udid"] as! String
        plTitleLabel.setText(title)
        plChannelName.setText(channelName)
        bannerImage1.sd_setImage(with: URL(string: plData["1"] as! String))
        bannerImage2.sd_setImage(with: URL(string: plData["2"] as! String))
        
        pageControl.setHidden(true)
        let path = "https://\(UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? Constants.defaultInstance)/api/v1/playlists/\(plid)"
        
        AF.request(path){ $0.timeoutInterval = 10 }.responseJSON {res in
            switch res.result {
            case .success(let data):
                let json = data as! Dictionary<String,Any>
                //first add missing data to the view
                if meta.getChannelInfo(udid: plData["udid"] as! String, key: "thumbnail") as! String != "???" {
                    self.plChannelImg.sd_setImage(with: URL(string: meta.getChannelInfo(udid: plData["udid"] as! String, key: "thumbnail") as! String))
                }
                if json["mixId"] != nil {
                    let back = WKAlertAction(title: "Back", style: .default, handler: {self.pop()})
                    self.presentAlert(withTitle: "Error", message: "YouTube mixes do not work with WatchTube yet. Sorry!", preferredStyle: .alert, actions: [back])
                    return
                }
                self.list = json["videos"] as! Array<Dictionary<String,Any>>
                if self.list.count > 2 {
                    let thumbs = self.list[3]["videoThumbnails"] as! Array<Dictionary<String,Any>>
                    let url = thumbs[0]["url"] as! String
                    self.bannerImage3.sd_setImage(with: URL(string: url))
                }
                // if the page max is greater than list length, dont show the controls
                if (self.list.count >= UserDefaults.standard.integer(forKey: settingsKeys.itemsCount)) == false {
                    self.pageControl.setHidden(true)
                } else {
                    self.pageControl.setHidden(false)
                }
                self.separatorTotalLabel.setText("Videos (\(self.list.count))")
                
                self.setupTable()
                
            case .failure(let error):
                
                let goPop = WKAlertAction(title: "Back", style: .default, handler: {self.pop()})
                let errorView = WKAlertAction(title: "View Error", style: .default, handler: {
                    self.presentAlert(withTitle: "Error", message: "\(error)", preferredStyle: .alert, actions:[goPop])
                })
                self.presentAlert(withTitle: "An error occurred", message: "We couldn't load the playlist information", preferredStyle: .sideBySideButtonsAlert, actions: [goPop,errorView])
            }
        }
        // Configure interface objects here.
        
    }
    
    @IBAction func nextPagePressed() {
        let dict: [String : Any] = [
            "page": 2,
            "list": list
        ]
        pushController(withName: "SubPlaylistInterfaceController", context: dict)
    }
    
    func setupTable() {
        
        let constant = UserDefaults.standard.integer(forKey: settingsKeys.itemsCount)
        let page = 1
        let rangeLower = (page - 1) * constant
        var rangeHigher = rangeLower + (constant - 1)
        if list.count < rangeHigher {rangeHigher = list.count}
        
        playlistTableRow.setNumberOfRows((rangeHigher - rangeLower) + 1, withRowType: "PlaylistRow")
        
        for index in rangeLower ..< rangeHigher + 1 {
            let i = index
            guard let row = playlistTableRow.rowController(at: i) as? PlaylistTableRow else {
                continue
            }
            let video = list[i]
            
            meta.cacheVideoInfo(id: video["videoId"] as! String)
            
            row.playlistItemTitle.setText(video["title"] as? String)
            row.videoId = video["videoId"] as? String
            row.playlistItemChannel.setText(video["author"] as? String)

            let thumbs = video["videoThumbnails"] as! Array<Dictionary<String,Any>>
            let url = thumbs[0]["url"] as! String
            
            if UserDefaults.standard.bool(forKey: settingsKeys.thumbnailsToggle) == false {
                row.playlistItemThumbnail.setHidden(true)
            } else {
                row.playlistItemThumbnail.sd_setImage(with: URL(string: url))
            }
        }
        
        playlistTableRow.setHidden(false)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt i: Int) {
        let item = list[i]
        let id = item["videoId"] as! String
        let title = item["title"] as! String
        let thumbs = item["videoThumbnails"] as! Array<Dictionary<String,Any>>
        let img = thumbs[0]["url"] as! String
        let channel = item["author"] as! String
        let type = "video"
        let vid = Video.init(id: id, title: title, img: img, channel: channel, subs: "", type: type)
        self.pushController(withName: "NowPlayingInterfaceController", context: vid)
    }
    
    @IBAction func openChannel(_ sender: Any) {
        if (meta.getChannelInfo(udid: udid, key: "name") as! String) == "???" {
            let ok = WKAlertAction(title: "Okay", style: .default) {}
            presentAlert(withTitle: "Slow Down!", message: "We're still waiting for the data you requested. Wait just a second!", preferredStyle: .alert, actions: [ok])
        } else {
            pushController(withName: "ChannelViewInterfaceController", context: udid)
        }
    }
}
