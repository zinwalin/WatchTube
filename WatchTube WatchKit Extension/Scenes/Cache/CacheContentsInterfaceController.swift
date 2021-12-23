//
//  CacheContentsInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 07/12/2021.
//

import WatchKit
import Foundation
import SDWebImage

class CacheContentsInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var cacheTableRow: WKInterfaceTable!
    var ids = [String]()
    @IBOutlet weak var disabledLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        //load videos with accompanying metadata.
        
        cacheTableRow.setNumberOfRows(0, withRowType: "cachedVideoRow")
        
        cacheTableRow.setHidden(true)
        if UserDefaults.standard.bool(forKey: settingsKeys.cacheToggle) == false {
            disabledLabel.setHidden(false)
        } else {
            disabledLabel.setHidden(true)
            do {
                var files = [String]()
                files = try FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory()+"/Documents/cache")
                if files.count == 0 {
                    disabledLabel.setHidden(false)
                    disabledLabel.setText("Cache is empty")
                } else {
                    disabledLabel.setHidden(true)
                    disabledLabel.setText("Cache is disabled")
                }
                for file in files {
                    let videoID = file.components(separatedBy: ".")[0]
                    if ids.contains(videoID) {
                        continue
                    } else {
                        ids.append(videoID)
                    }
                }
                cacheTableRow.setNumberOfRows(ids.count, withRowType: "cachedVideoRow")
                cacheTableRow.setHidden(false)
                
                for i in 0 ..< ids.count {
                    let videoID = ids[i]
                    guard let row = cacheTableRow.rowController(at: i) as? CacheTableRow else {
                        continue
                    }
                    
                    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let dataFileURL = dir.appendingPathComponent("miscCache/"+videoID)
                        
                        let data = try String(contentsOf: dataFileURL, encoding: .utf8).components(separatedBy: "\n")
                        // ok so data[0] is the video title and data[1] is image url
                        row.cacheTitleLabel.setText(data[0])
                        row.cacheThumbImage.sd_setImage(with: URL(string: data[1]))
                        row.videoId = videoID
                        var totalSize = 0 as Int64
                        if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: NSHomeDirectory()+"/Documents/cache/\(videoID).mp4") {
                            if let bytes = fileAttributes[.size] as? Int64 {
                                totalSize = totalSize+bytes
                            }
                        }
                        if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: NSHomeDirectory()+"/Documents/cache/\(videoID).mp3") {
                            if let bytes = fileAttributes[.size] as? Int64 {
                                totalSize = totalSize+bytes
                            }
                        }
                        let bcf = ByteCountFormatter()
                        if ((totalSize >= 1024000000) == true) {bcf.allowedUnits = [.useGB]} else {bcf.allowedUnits = [.useMB]}
                        bcf.countStyle = .file
                        let string = bcf.string(fromByteCount: totalSize)
                        row.cacheFilesize.setText(string)
                    }
                }
                
                
            } catch {
                //no errors should occur i hope
            }
        }
                
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.pushController(withName: "CacheNowPlayingInterfaceController", context: String(self.ids[rowIndex]))
    }

}