//
//  hlsPlayer.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 10/02/2022.
//

import WatchKit
import Foundation
import SwiftUI
import Alamofire

class hlsPlayer: WKHostingController<playerView> {
    override var body: playerView {
        return playerView()
    }
}
