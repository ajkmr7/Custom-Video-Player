/// A struct representing the configuration for the video player.
public struct VideoPlayerConfig {
    var playlist: VideoPlaylist
    
    /// Initializes a `VideoPlayerConfig` with the specified playlist.
    ///
    /// - Parameter playlist: The playlist for the video player.
    public init(playlist: VideoPlaylist) {
        self.playlist = playlist
    }
}

/// A struct representing a video playlist.
public struct VideoPlaylist {
    let title: String
    var currentVideoIndex: Int?
    let videos: [Video]?
    
    /// Initializes a `VideoPlaylist` with the specified title, current video index, and videos.
    ///
    /// - Parameters:
    ///   - title: The title of the playlist.
    ///   - currentVideoIndex: The index of the currently playing video in the playlist (default is nil).
    ///   - videos: An array of `Video` objects in the playlist (default is nil).
    public init(title: String, currentVideoIndex: Int? = nil, videos: [Video]?) {
        self.title = title
        self.currentVideoIndex = currentVideoIndex
        self.videos = videos
    }
}

/// A struct representing a video.
public struct Video {
    let url: String?
    let title: String?
    let isLiveContent: Bool?
    
    /// Initializes a `Video` with the specified URL, title, and whether it is live content.
    ///
    /// - Parameters:
    ///   - url: The URL of the video.
    ///   - title: The title of the video (default is nil).
    ///   - isLiveContent: A boolean indicating whether the video is live content (default is false).
    public init(url: String?, title: String? = nil, isLiveContent: Bool? = false) {
        self.url = url
        self.title = title
        self.isLiveContent = isLiveContent
    }
}
