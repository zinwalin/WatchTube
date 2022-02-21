//
//  Settings.swift
//  WatchTube WatchKit Extension
//
//  Created by developer on 12/6/20.
//

import Foundation
struct preferencesKeys {
    static let keywordsHistory = "keywordsHistory"
}

struct settingsKeys {
    static let thumbnailsToggle = "settings.thumbnailsToggleKey"
    static let audioOnlyToggle = "settings.audioOnlyToggleKey"
    static let resultsCount = "settings.resultsCount"
    static let itemsCount = "settings.itemsCount"
    static let homePageVideoType = "settings.homePageVideoType"
    static let instanceUrl = "settings.instanceUrl"
    static let qualityToggle = "settings.qualityToggle"
}

struct Constants {
    static let defaultInstance = "invidious.osi.kr"
}

struct hls {
    static let url = "hls.streamUrl"
}
