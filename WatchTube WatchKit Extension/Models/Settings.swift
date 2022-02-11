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
    static let cacheToggle = "settings.cacheToggleKey"
    static let thumbnailsToggle = "settings.thumbnailsToggleKey"
    static let audioOnlyToggle = "settings.audioOnlyToggleKey"
    static let resultsCount = "settings.resultsCount"
    static let itemsCount = "settings.itemsCount"
    static let homePageVideoType = "settings.homePageVideoType"
    static let instanceUrl = "settings.instanceUrl"
    static let proxyContent = "settings.proxyContent"
    static let qualityToggle = "settings.qualityToggle"
    static let hlsToggle = "settings.hlsToggle"
}

struct miscKeys {
    static let pushToCacheContents = "misc.pushToCacheContents"
    static let isDebug = "misc.isDebug"
}

struct Constants {
    static let defaultInstance = "invidious.osi.kr"
}

struct hls {
    static let url = "hls.streamUrl"
    static let title = "hls.title"
    static let id = "hls.id"
    static let udid = "hls.udid"
    static let channel = "hls.channel"
}
