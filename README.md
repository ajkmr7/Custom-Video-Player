# Custom Video Player

A feature-rich video player with custom playback controls, subtitle and video quality selection, live streaming, and robust error handling.

<center>
<img src="https://miro.medium.com/v2/resize:fit:1400/format:webp/1*GAx2shPD5ZQyfiQtk2GNWQ.png" width="75%"/>
</center>

## Features

- **Custom Playback Controls**
- **Video Playlist**
- **Subtitle Selection**
- **Video Quality Selection**
- **Live Stream Support**
- **Error Handling**

## Requirements

- iOS 11.0 or later

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Custom Video Player into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target '<Your Target Name>' do
   pod 'Custom-Video-Player', :git => 'https://github.com/ajkmr7/Custom-Video-Player.git', :tag => '1.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

To integrate Custom Video Player into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ajkmr7/Custom-Video-Player.git")
]
```

## Usage

Initialize and configure the player with a video playlist. The playlist should have a _title_ and a list of _videos_, with each video having its own _title, URL, and isLiveContent_ attribute.

   ```swift
   let playlist = VideoPlaylist(
      title: "IPTV",
      videos: [
         Video(
               url: "https://ndtvindiaelemarchana.akamaized.net/hls/live/2003679/ndtvindia/master.m3u8",
               title: "NDTV",
               isLiveContent: true
         ),
         Video(
               url: "https://segment.yuppcdn.net/050522/murasu/050522/murasu_1200/chunks.m3u8",
               title: "Murasu",
               isLiveContent: true
         ),
         Video(
               url: "https://ndtv24x7elemarchana.akamaized.net/hls/live/2003678/ndtv24x7/masterp_480p@1.m3u8",
               title: "NDTV.com",
               isLiveContent: true
         ),
      ]
   )
   let config = VideoPlayerConfig(playlist: playlist)
   ```

Initialize the _VideoPlayerCoordinator_ with your base UINavigationController and invoke the player with the configuration.

   ```swift
   let coordinator = VideoPlayerCoordinator(navigationController: navigationController)
   coordinator.invoke(videoPlayerConfig: config)

   ```

## Sample App

To see a working implementation of the Custom Video Player, you can use the Example app provided in the repository. Follow these steps to set it up:

1. Clone this repository.

   ```bash
   git clone https://github.com/ajkmr7/Custom-Video-Player.git
   ```

2. Navigate to the `Example` directory and install the necessary pods.

   ```bash
   cd Custom-Video-Player/Example
   pod install
   ```

3. Open the workspace in Xcode.

   ```bash
   open Custom-Video-Player.xcworkspace
   ```

4. Build and run the project on your device or simulator.

## Sample Use Case: Watch Party

We have a branch with a sample use case demonstrating how to implement a Watch Party feature. Check out the `watch-party` branch to see this in action.

<center>
<img src="https://miro.medium.com/v2/resize:fit:1000/format:webp/1*p-2rYucmrxubb5XfuAVqfA.png" width="75%"/>
</center>

## Articles for Further Implementation

For more detailed guidance on customizing and extending the player, refer to the following articles:

- [Part 1 — Mastering Custom Control Setup](https://ajkmr7.medium.com/crafting-the-ultimate-ios-video-player-part-1-mastering-custom-control-setup-30732b12ab37)
- [Part 2 — Demystifying Subtitle Handling](https://ajkmr7.medium.com/demystifying-subtitle-handling-in-ios-apps-a-swift-avplayer-tutorial-1d60eab06f87)
- [Part 3 — Exploring Video Quality Selection](https://ajkmr7.medium.com/crafting-the-ultimate-ios-video-player-part-3-exploring-video-quality-selection-670b38f06962)
- [Part 4 — Elevating Your Player with Live Content Support](https://ajkmr7.medium.com/crafting-the-ultimate-ios-video-player-part-4-elevating-your-player-with-live-content-support-cc21fa50c1a6)
- [Bonus — Watch Party Integration](https://ajkmr7.medium.com/watchcrafting-the-ultimate-ios-video-player-bonus-watch-party-integration-13be7e7685bb)
