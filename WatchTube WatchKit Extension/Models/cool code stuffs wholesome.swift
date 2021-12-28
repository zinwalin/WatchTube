//
//  cool code stuffs wholesome.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 27/12/2021.
//

import Foundation
import Alamofire

class Global {
    class func cacheVideoInfo(id: String) {
        AF.request("https://\(Constants.downloadSrvInstance)/api/v1/getInfo?url=https://youtu.be/\(id)").responseJSON { response in
            switch response.result {
            case .success(let json):
                let response = json as! Dictionary<String, Any>
                if response["videoDetails"] != nil {
                    let videoDetails = response["videoDetails"] as! Dictionary<String, Any>
                    var data = [String: Any]()
                    data["title"] = videoDetails["title"] as? String
                    data["channelId"] = (videoDetails["author"] as! Dictionary<String, Any>)["id"] as? String
                    data["channelName"] = (videoDetails["author"] as! Dictionary<String, Any>)["name"] as? String
                    data["thumbnail"] = "https://i.ytimg.com/vi/\(id)/maxresdefault.jpg"
                    data["likes"] = videoDetails["likes"] as? Int
                    data["description"] = videoDetails["description"] as? String
                    data["views"] = videoDetails["viewCount"] as? String
                    data["category"] = videoDetails["category"] as? String
                    data["lengthSeconds"] = videoDetails["lengthSeconds"] as? String
                    data["publishedDate"] = (videoDetails["publishDate"] as? String)!.components(separatedBy: "-").reversed().joined(separator: "/")
                    data["related_videos"] = videoDetails["related_videos"]
                    
                    do {
                        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let fileURL = dir.appendingPathComponent("miscCache/"+id)
                            try FileManager.default.createDirectory(at: dir.appendingPathComponent("miscCache"), withIntermediateDirectories: true)
                            //writing
                            NSDictionary(dictionary: data).write(to: fileURL, atomically: true)
                        }
                    } catch {}
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // if you cant read this line, its a function in a class (made for superbro)
    class func getVideoInfo(id: String, key: String? = nil) -> Any {
        // id is the id of the video, is ofc required
        //     and key is optional, gets key from meta file for you if you want
        
        // check if meta file exists
        if FileManager.default.fileExists(atPath: NSHomeDirectory()+"/Documents/miscCache/\(id)") == false {
            // file doesnt exist, quickly get the data now
            self.cacheVideoInfo(id: id)
        }
        
        // file exists, get file path url for doc dir
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // attach the rest of the path
            let fileURL = dir.appendingPathComponent("miscCache/"+id)

            // load file as nsdictionary
            let data = NSDictionary(contentsOf: fileURL)
            
            
            
            // if key was provided...
            if (key != nil) {
                // ...check if the key exists in the dictionary. if it exists...
                if data![key!] != nil {
                    // ...return the key's value
                    return data![key!]!
                } else {
                    // ...return the entire data structure
                    return data as Any
                }
            } else {
                // key was not provided. return the entire data structure
                return data as Any
            }
        }
        // wtf happened
        return "Unknown error"
    }
}
