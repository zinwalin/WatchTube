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
    var subs: String
    var type: String
    public init(id: String, title: String, img: String, channel: String, subs: String, type: String) {
        self.id = id
        self.title = title
        self.img = img
        self.channel = channel
        self.subs = subs
        self.type = type
     }
    
    class func getSearchResults(keyword: String, completion: @escaping ([Video]) -> Void) {
        let path = "https://\(UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? Constants.defaultInstance)/api/v1/search?q=\(keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&type=all"
        AF.request(path).responseJSON { response in
            var videos = [Video]()
            switch response.result {
            case .success(let json):
                let response = json as! Array<Dictionary<String, Any>>
                for (i, item) in response.enumerated() {
                    
                    if i > (UserDefaults.standard.integer(forKey: settingsKeys.resultsCount) - 1) {break}
                    
                    let type = item["type"] as! String
                    switch type {
                    case "video":
                        
                        if (item["videoId"] as! String).count != 11 {continue}
                        
                        // is video, add necessary data
                        let id = item["videoId"] as! String
                        let title = item["title"] as! String
                        let thumbs = item["videoThumbnails"] as! Array<Dictionary<String,Any>>
                        let url = thumbs[0]["url"] as! String
                        let channel = item["author"] as! String
                        let vid = Video(id: id, title: title, img: url, channel: channel, subs: "", type: item["type"] as! String)
                        videos.append(vid)
                        
                    case "channel":
                        
                        if (item["authorId"] as! String).count != 24 {continue}
                        
                        // is channel, add necessary data
                        
                        let udid = item["authorId"] as! String
                        let thumbs = item["authorThumbnails"] as! Array<Dictionary<String,Any>>
                        let url = thumbs[thumbs.count - 1]["url"] as! String
                        let channel = item["author"] as! String
                        let subs = (item["subCount"] as! Int).abbreviated
                        var imgurl: String!
                        if url.contains("https:") {
                            imgurl = "\(url)"
                        } else {
                            imgurl = "https:\(url)"
                        }
                        let vid = Video(id: udid, title: "", img: imgurl, channel: channel, subs: subs, type: item["type"] as! String)
                        videos.append(vid)
                        
                    case "playlist":
                        
                        let plid = item["playlistId"] as! String
                        let videosArray = item["videos"] as! Array<Any>
                        var plThumb: String = "egg"
                        var two = ""
                        var one = (((videosArray[0] as! Dictionary<String,Any>)["videoThumbnails"] as! Array<Any>)[((videosArray[0] as! Dictionary<String,Any>)["videoThumbnails"] as! Array<Any>).count - 1] as! Dictionary<String,Any>)["url"] as! String
                        if videosArray.count > 1 {
                            two = (((videosArray[1] as! Dictionary<String,Any>)["videoThumbnails"] as! Array<Any>)[((videosArray[1] as! Dictionary<String,Any>)["videoThumbnails"] as! Array<Any>).count - 1] as! Dictionary<String,Any>)["url"] as! String
                        }
                        
                        // because low res thumbnails are shit, imma change them to highres ones
                        one = (URL(string: one)?.deletingLastPathComponent().appendingPathComponent("maxresdefault.jpg").absoluteString)!
                        if two.contains("http"){
                        two = (URL(string: two)?.deletingLastPathComponent().appendingPathComponent("maxresdefault.jpg").absoluteString)!
                        }
                        
                        plThumb = "\(one)\n\(two)"
                        
                        let name = item["title"] as! String
                        let channel = item["author"] as! String
                        let udid = item["authorId"] as! String
                        
                        let vid = Video(id: plid, title: name, img: plThumb, channel: channel, subs: udid, type: item["type"] as! String)
                        videos.append(vid)
                    default:
                        break
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
            let trendingpath = "https://\(UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? Constants.defaultInstance)/api/v1/trending?type=\(UserDefaults.standard.string(forKey: settingsKeys.homePageVideoType) ?? "default")&fields=title,videoId,author,videoThumbnails"
            AF.request(trendingpath) {$0.timeoutInterval = 10}.validate().responseJSON { response in
                var videos = [Video]()
                switch response.result {
                case .success(let json):
                    let items = json as? [[String: Any]] ?? []
                    for (i, item) in items.enumerated() {
                        if i > (UserDefaults.standard.integer(forKey: settingsKeys.itemsCount) - 1) {continue}
                        let title = item["title"]
                        let vidId = item["videoId"]
                        let channel = item["author"]
                        let thumbnail = (item["videoThumbnails"] as! Array<Dictionary<String, Any>>)[1]["url"] as! String
                        if title == nil || vidId == nil || channel == nil {
                            continue
                        } else {
                            let video = Video(id: vidId as! String, title: title as! String, img: thumbnail, channel: channel as! String, subs: "", type: "video")
                            videos.append(video)
                        }
                    }
                case .failure(_):
                    print("man no internet")
                }
                completion(videos)
            }
        } else {
            // scrape favourite channels for videos
        }
    }
}

