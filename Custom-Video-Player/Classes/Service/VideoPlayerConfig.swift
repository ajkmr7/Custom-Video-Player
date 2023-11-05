public struct VideoPlayerConfig {
    var playlist: VideoPlaylist
    
    public init(playlist: VideoPlaylist) {
        self.playlist = playlist
    }
}

public struct VideoPlaylist {
    let title: String
    var currentVideoIndex: Int?
    let videos: [Video]?
    
    public init(title: String, currentVideoIndex: Int? = nil, videos: [Video]?) {
        self.title = title
        self.currentVideoIndex = currentVideoIndex
        self.videos = videos
    }
}

public struct Video {
    let url: String?
    let title: String?
    
    public init(url: String?, title: String? = nil) {
        self.url = url
        self.title = title
    }
}
