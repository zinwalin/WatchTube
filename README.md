WatchTube is a standalone WatchOS YouTube player utilizing [Invidious](https://invidious.io) for metadata and [YouTubeKit](https://github.com/alexeichhorn/YouTubeKit) for streaming. The app is based off of [Ziph0n's original Wristplayer](https://github.com/Ziph0n/WristPlayer) and is a fork of [akissu's youtubedl-watchos](https://github.com/akissu/youtubedl-watchos), it aims to achieve the following:

1. Fully standalone usage of the app relying on Invidious to not use the official YouTube API and avoid ratelimits

2. Not requiring people to provide a YouTube API Key for usage

3. Free alternative to other apps on the App Store since you shouldn't be paying for, what is essentially, a gimmick

4. There are no working apps that do this on GitHub already

5. It should look nice

# Installing
[Open in TestFlight](https://testflight.apple.com/join/tpwIQJIR)

# Building from source

0. OPTIONAL: Star this repo :)
1. Clone the repo to any location to open in Xcode
2. Open the xcodeproj file or open Xcode and open existing project
3. Replace all of the signing and team identifiers in Xcode
> Replace the bundle ID for all 3 targets with something unique. Don't forget to replace bundle ID in the `info.plist` file in the watchkit extension folder. Expand NSExtension and expand NSExtensionAttributes to find WKAppBundleIdentifier.
Make sure you add your Apple ID to Xcode or else your personal team will not appear.
4. Build and deploy WatchOS app
> Plug your iPhone into your Mac and it should start preparing both devices for development.

> We've had plenty of people have their Xcode progress stuck on "Running WatchTube". If this happens to you, make sure Xcode isn't installing any device support. If it is, wait. If not, restart Xcode and run the app again.
4. Exhale 😮‍💨

# Demonstrations

Using v1.0.4

![](./demo/1.gif)
> Note that this is a demonstration of the simulator. The video playback controls were odd and the videos look long to load. This is not a problem on real devices.

More demonstrations coming soon!
