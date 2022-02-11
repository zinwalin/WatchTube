//
//  PreloadInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 10/02/2022.
//

import WatchKit
import Foundation
import Alamofire

class PreloadInterfaceController: WKInterfaceController {
    var shouldPop = 0
    override func awake(withContext context: Any?) {
        
        super.awake(withContext: context)
        
        // load up the swiftui view instead
        let id = context as! String
        var quality = ""
        var dlType: String // set filetypes as requested or needed
        if UserDefaults.standard.bool(forKey: settingsKeys.audioOnlyToggle) == false {
            dlType = "video"
        } else {
            dlType = "audio"
        }
        
        // true is hd
        if UserDefaults.standard.bool(forKey: settingsKeys.qualityToggle) == true {
            quality="hd"
        } else {
            quality="sd"
        }
        
        let dataPath = "https://\(UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? Constants.defaultInstance)/api/v1/videos/\(id)?fields=title,author,authorId,formatStreams(url,container),adaptiveFormats(url,container,encoding,bitrate)"
        var streamUrl = ""
        var udid = ""
        var title = ""
        var channel = ""

        AF.request(dataPath).responseJSON { res in
            switch res.result {
            case .success(let data):
                let videoDetails = data as! Dictionary<String, Any>

                // Required variables in this scope
                // - streamUrl (to set)
                // - fileType (to set)
                // - dlType (to use)
                
                // parse the video info for links. check dl type to set streamUrl to src of audio or video
                
                if (videoDetails["adaptiveFormats"] as! Array<Dictionary<String, Any>>).count == 0 || (videoDetails["formatStreams"] as! Array<Dictionary<String, Any>>).count == 0 {
                    self.presentAlert(withTitle: "An error occurred", message: "We couldn't find a stream, this might be an invalid video.", preferredStyle: .alert, actions: [WKAlertAction(title: "Ok", style: .default, handler: {})])
                    return
                }
                
                udid = videoDetails["authorId"] as! String
                channel = videoDetails["author"] as! String
                title = videoDetails["title"] as! String

                if dlType == "video" {
                    let formatStreams = videoDetails["formatStreams"] as! Array<Dictionary<String, Any>>
                    if quality == "hd" {
                        let streamData = formatStreams[formatStreams.count - 1]
                        streamUrl = streamData["url"] as! String
                    } else if quality == "sd" {
                        var streamData: Dictionary<String,String>
                        if formatStreams.count >= 2 {
                            streamData = formatStreams[1] as! Dictionary<String,String>
                        } else {
                            streamData = formatStreams[0] as! Dictionary<String,String>
                        }
                        streamUrl = streamData["url"]!
                    }
                } else if dlType == "audio" {
                    let adaptiveFormats = videoDetails["adaptiveFormats"] as! Array<Dictionary<String, Any>>
                    var aacFormats: Array<Dictionary<String, Any>> = []
                    for item in adaptiveFormats {
                        if item["encoding"] != nil {
                            if item["encoding"] as! String == "aac" {
                                aacFormats.append(item)
                            }
                        }
                    }
                    
                    var highestBitrate: Int = 0
                    if quality == "sd" {highestBitrate = Int.max}
                    var format: Dictionary<String, Any> = [:]
                    if aacFormats.count != 1 {
                        for item in aacFormats {
                            if quality == "hd" {
                                if (item["bitrate"] as! NSString).integerValue > highestBitrate {
                                    highestBitrate = (item["bitrate"] as! NSString).integerValue
                                    format = item
                                }
                            } else if quality == "sd" {
                                if (item["bitrate"] as! NSString).integerValue < highestBitrate {
                                    highestBitrate = (item["bitrate"] as! NSString).integerValue
                                    format = item
                                }
                            }
                        }
                    } else {format = aacFormats[0]}
                    streamUrl = format["url"] as! String
                }
                
                if UserDefaults.standard.bool(forKey: settingsKeys.proxyContent) {
                    // modify streamURL to use instance proxying
                    let host = (URL(string: streamUrl)?.host)! as String
                    streamUrl = streamUrl.replacingOccurrences(of: host, with: UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? Constants.defaultInstance)
                }
                
                UserDefaults.standard.set(streamUrl, forKey: hls.url)
                UserDefaults.standard.set(title, forKey: hls.title)
                UserDefaults.standard.set(id, forKey: hls.id)
                UserDefaults.standard.set(channel, forKey: hls.channel)
                UserDefaults.standard.set(udid, forKey: hls.udid)

                self.shouldPop = 1
                self.pushController(withName: "HlsPlayer", context: "")
            case .failure(_):
                self.presentAlert(withTitle: "An error occurred", message: "We couldn't connect to the API", preferredStyle: .alert, actions: [WKAlertAction(title: "Ok", style: .default, handler: {})])
                return
            }
        }
    }
    
    override func willActivate() {
        if shouldPop == 1 {
            pop()
        }
    }
}
