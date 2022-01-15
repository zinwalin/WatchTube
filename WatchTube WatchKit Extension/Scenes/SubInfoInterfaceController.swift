//
//  SubInfoInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 13/12/2021.
//

import WatchKit
import Foundation


class SubInfoInterfaceController: WKInterfaceController {
    @IBOutlet weak var bodyLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        bodyLabel.setText(context as? String)
        // Configure interface objects here.
    }

}
