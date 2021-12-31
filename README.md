WatchTube is a standalone WatchOS youtube player utilizing [Download API](https://github.com/llsc12/download-api) for search data and video streaming. The app is based off of [Ziph0n's original Wristplayer](https://github.com/Ziph0n/WristPlayer) and is a fork of [akissu's youtubedl-watchos](https://github.com/akissu/youtubedl-watchos), it aims to achieve the following:

1. Fully standalone usage of the app relying on Download API to not use the official YouTube API and avoid ratelimits

2. Not requiring people to provide a YouTube API Key for usage

3. Free alternative to other apps on the App Store since you shouldn't be paying for, what is essentially a gimmick

# Installation

0. OPTIONAL: Star this repo :)
1. OPTIONAL: Setup your own [Download API instance](https://github.com/llsc12/download-api)
2. Use your instance's address from step 1 to fill in `Settings.swift` or use `llsc12.ml` as default.
3. Replace all of the signing and team identifiers in Xcode
> Replace the bundle ID for all 3 targets with something unique. Don't forget to replace bundle ID in the `info.plist` file in the watchkit extension folder. Expand NSExtension and expand NSExtensionAttributes to find WKAppBundleIdentifier.
Make sure you add your Apple ID to Xcode or else your personal team will not appear.
4. Build and deploy WatchOS app
> Plug your iPhone into your Mac and it should start preparing both devices for development.
5. Exhale 😮‍💨

# Demonstrations
![](./demo/1.gif)
> Note that this is a demonstration of the simulator. The video playback controls were odd and the videos look long to load. This is not a problem on real devices.

More demonstrations coming soon!
