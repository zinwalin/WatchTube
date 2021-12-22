//
//  CacheInfoInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 12/12/2021.
//

import WatchKit
import Foundation
import Alamofire
import SwiftyJSON

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
    
    var videoDetails: Dictionary<String, Any> = [:]
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        videoId = context! as! String
        
        self.showDescriptionButton.setEnabled(false)
        self.likesLabel.setText("Loading Likes")
        self.viewsLabel.setText("Loading Views")
        self.dateLabel.setText("Loading Date")
        self.authorLabel.setText("Loading Channel")
        self.InfoCacheDeleteButton.setHidden(!(FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(context!).mp4") || FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(context!).mp3")))
        
        
        AF.request("https://"+Constants.downloadSrvInstance+"/api/v1/getInfo?url=\(context!)").responseJSON { response in
            
            switch response.result {
            case .success(let json):
                    let response = json as! Dictionary<String, Any>
                    let keyExists = response["videoDetails"]
                    if keyExists != nil{
                        self.videoDetails = response["videoDetails"] as! Dictionary<String, Any>
                    }
                    
            case .failure(let error):
                print(error)
            }
            let author = self.videoDetails["author"] as! Dictionary<String, Any>
            self.likesLabel.setText("\(String(describing: self.videoDetails["likes"]!)) Likes")
            self.viewsLabel.setText("\(String(describing: self.videoDetails["viewCount"]!)) Views")
            self.dateLabel.setText("Uploaded \(String(describing: self.videoDetails["publishDate"]!).components(separatedBy: "-").reversed().joined(separator: "/"))")
            self.authorLabel.setText("\(String(describing: author["name"]!))")
            self.showDescriptionButton.setEnabled(true)
        }

        
        // Configure interface objects here.
    }
    @IBAction func showDescription() {
        self.pushController(withName: "SubInfoInterfaceController", context: self.videoDetails["description"]!)
    }
    
    @IBAction func infoDeleteCache() {
        if (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(videoId).mp4")) {
            do {
                try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Documents/cache/\(videoId).mp4")
            } catch {}
        }
        if (FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/cache/\(videoId).mp3")) {
            do {
                try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Documents/cache/\(videoId).mp3")
            } catch {}
        }
        pop()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
