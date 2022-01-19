//
//  ProfileViewInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 19/01/2022.
//

import WatchKit
import Foundation
import SDWebImage

class ProfileViewInterfaceController: WKInterfaceController {
    @IBOutlet weak var image: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("Back")
        image.sd_setImage(with: URL(string: context as! String))
        // Configure interface objects here.
    }
}
