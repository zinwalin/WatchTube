//
//  Video.swift
//  WatchTube WatchKit Extension
//
//  Created by developer on 12/6/20.
//

import Foundation
import Alamofire
import SDWebImage

class Video {
    
    var id: String
    var title: String
    var img: String
    var channel: String
    public init(id: String, title: String, img: String, channel: String) {
        self.id = id
        self.title = title
        self.img = img
        self.channel = channel
     }
    
    class func getSearchResults(keyword: String, completion: @escaping ([Video]) -> Void) {
        AF.request("https://\(UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? "vid.puffyan.us")/api/v1/search?q=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&type=video&fields=title,videoId,author,videoThumbnails(url)").responseJSON { response in
            var videos = [Video]()
            switch response.result {
            case .success(let json):
                    let response = json as! Array<Dictionary<String, Any>>
                    for (_, item) in response.enumerated() {
                        let title = item["title"]
                        let vidId = item["videoId"]
                        let channel = item["author"] as? String
                        let url = (item["videoThumbnails"] as! Array<Dictionary<String, Any>>)[0]["url"] as! String
                        // cool also btw this is the search results thingy
                        if title == nil || vidId == nil || channel == nil {
                            //where data moment
                        } else {
                            let video = Video(id: vidId as! String, title: title as! String, img: url, channel: channel!)
                            videos.append(video)
                        }
                    }
            case .failure(let error):
                print(error)
            }
            completion(videos)
        }
    }
    
    class func getTrending(completion: @escaping ([Video]) -> Void) {
        if UserDefaults.standard.string(forKey: settingsKeys.homePageVideoType) != "channels" {
            AF.request("https://\(UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? "vid.puffyan.us")/api/v1/trending?type=\(UserDefaults.standard.string(forKey: settingsKeys.homePageVideoType) ?? "default")&fields=title,videoId,author,videoThumbnails(url)").responseJSON { response in
                var videos = [Video]()
                switch response.result {
                case .success(let json):
                        let items = json as! [[String: Any]]
                        for (i, item) in items.enumerated() {
                            if i > (UserDefaults.standard.integer(forKey: settingsKeys.itemsCount) - 1) {continue}
                            let title = item["title"]
                            let vidId = item["videoId"]
                            let channel = item["author"]
                            let thumbnail = (item["videoThumbnails"] as! Array<Dictionary<String, Any>>)[1]["url"] as! String
                            if title == nil || vidId == nil || channel == nil {
                                continue
                            } else {
                                let video = Video(id: vidId as! String, title: title as! String, img: thumbnail, channel: channel as! String)
                                videos.append(video)
                            }
                        }
                case .failure(let error):
                    print(error)
                }
                completion(videos)
            }
        } else {
            // scrape favourite channels for videos
        }
    }
}
