//
//  InfoInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 12/12/2021.
//

import WatchKit
import Foundation
import Alamofire

class InfoInterfaceController: WKInterfaceController {
    @IBOutlet weak var viewsIcon: WKInterfaceImage!
    @IBOutlet weak var likesIcon: WKInterfaceImage!
    @IBOutlet weak var authorIcon: WKInterfaceImage!
    @IBOutlet weak var uploadIcon: WKInterfaceImage!
    
    @IBOutlet weak var subsLabel: WKInterfaceLabel!
    @IBOutlet weak var subtitlePicker: WKInterfacePicker!
    
    @IBOutlet weak var viewsLabel: WKInterfaceLabel!
    @IBOutlet weak var likesLabel: WKInterfaceLabel!
    @IBOutlet weak var dateLabel: WKInterfaceLabel!
    @IBOutlet weak var authorLabel: WKInterfaceLabel!
    
    @IBOutlet weak var showDescriptionButton: WKInterfaceButton!
    
    var videoId: String = ""
    var udid: String = ""
    var quality: String = ""
    var language: [String] = []

    var videoDetails: Dictionary<String, Any> = [:]
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let data = context as! Dictionary<String, String>
        videoId = data["id"]!
        quality = data["quality"]!
        udid = meta.getVideoInfo(id: videoId, key: "channelId") as! String

        self.showDescriptionButton.setEnabled(false)
        self.likesLabel.setText("Loading Likes")
        self.viewsLabel.setText("Loading Views")
        self.dateLabel.setText("Loading Date")
        self.authorLabel.setText("Loading Channel")
        
        let likes = (meta.getVideoInfo(id: videoId, key: "likes") as! Int).abbreviated
        let views = (meta.getVideoInfo(id: videoId, key: "views") as! Int).abbreviated
        self.likesLabel.setText("\(likes) Likes")
        self.viewsLabel.setText("\(views) Views")
        self.dateLabel.setText("Uploaded \(String(describing: meta.getVideoInfo(id: videoId, key: "publishedDate")))")
        self.authorLabel.setText("\(String(describing: meta.getVideoInfo(id: videoId, key: "channelName")))")
        self.showDescriptionButton.setEnabled(true)
        let capspath = "https://\(UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? Constants.defaultInstance)/api/v1/videos/\(video.id)?fields=captions"
        print(capspath)
        AF.request(capspath).responseJSON { res in
            switch res.result {
                case .success(let data):
                let captions = (data as? Dictionary<String, Array<Any>>)!["captions"] ?? []
                self.subsLabel.setText("Captions (\(captions.count))")
                
                var data: Array<Array<String>> = []
                for item in captions {
                    let captionset = item as! Dictionary<String, String>
                    let langcode = captionset["language_code"]!
                    let labeltext = captionset["label"]!
                    self.language.append(langcode)
                    data.append([labeltext, langcode])
                }
                data.insert(["Off", "off"], at: 0)
                let items: [WKPickerItem] = data.map {
                    let pickerItem = WKPickerItem()
                    pickerItem.title = $0[0]
                    pickerItem.caption = $0[1]
                    return pickerItem
                }
                self.subtitlePicker.setItems(items)
                case .failure(_):
                self.subsLabel.setText("Captions (Error)")
                var data: Array<Array<String>> = []
//                for item in captions {
//                    let captionset = item as! Dictionary<String, String>
//                    let langcode = captionset["language_code"]!
//                    let labeltext = captionset["label"]!
//                    self.language.append(langcode)
//                    data.append([labeltext, langcode])
//                }
                data.insert(["Off", "off"], at: 0)
                let items: [WKPickerItem] = data.map {
                    let pickerItem = WKPickerItem()
                    pickerItem.title = $0[0]
                    pickerItem.caption = $0[1]
                    return pickerItem
                }
                self.subtitlePicker.setItems(items)
            }
        }
        
        // Configure interface objects here.
    }
    
    @IBAction func pickerChanged(_ value: Int) {
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
