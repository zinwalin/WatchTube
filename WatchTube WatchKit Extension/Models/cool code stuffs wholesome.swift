//
//  cool code stuffs wholesome.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 27/12/2021.
//

import Foundation
import Alamofire

class meta {
    class func cacheVideoInfo(id: String) {
        AF.request("\(Constants.apiUrl)/videos/\(id)?fields=title,author,authorId,videoThumbnails(url),likeCount,description,viewCount,genre,lengthSeconds,published").responseJSON { response in
            switch response.result {
            case .success(let json):
                let videoDetails = json as! Dictionary<String, Any>
                var data = [String: Any]()
                data["title"] = videoDetails["title"] as? String
                data["channelId"] = videoDetails["authorId"] as? String
                data["channelName"] = videoDetails["author"] as? String
                data["thumbnail"] = (videoDetails["videoThumbnails"] as! Array<Dictionary<String, Any>>)[0]["url"] as! String
                data["likes"] = videoDetails["likeCount"] as? Int
                data["description"] = videoDetails["description"] as? String
                data["views"] = videoDetails["viewCount"] as? Int
                data["category"] = videoDetails["genre"] as? String
                data["lengthSeconds"] = videoDetails["lengthSeconds"] as? String
//                data["related_videos"] = videoDetails["recommendedVideos"] this causes meta to not save, causes nilErrors
                let date = Date(timeIntervalSince1970: (videoDetails["published"] as? Double)!)
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.short //Set date style
                dateFormatter.timeZone = .current
                data["publishedDate"] = dateFormatter.string(from: date)
                
                do {
                    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let fileURL = dir.appendingPathComponent("miscCache/"+id)
                        try FileManager.default.createDirectory(at: dir.appendingPathComponent("miscCache"), withIntermediateDirectories: true)
                        //writing
                        NSDictionary(dictionary: data).write(to: fileURL, atomically: true)
                    }
                } catch {print(error)}
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
            if let data = NSDictionary(contentsOf: fileURL) {
                // if key was provided...
                if (key != nil) {
                    // ...check if the key exists in the dictionary. if it exists...
                    if data[key!] != nil {
                        // ...return the key's value
                        return data[key!]!
                    } else {
                        // ...return the entire data structure
                        return data as Any
                    }
                } else {
                    // key was not provided. return the entire data structure
                    return data as Any
                }
            } else {
                return "???"
            }
        }
        // wtf happened
        return "???"
    }
}
