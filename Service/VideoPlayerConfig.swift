public struct VideoPlayerConfig {
    let playlist: VideoPlaylist
}

public struct VideoPlaylist {
    let title: String
    var currentVideoIndex: Int?
    let videos: [Video]?
}

public struct Video {
    let url: String?
    let title: String?
    
    init(url: String?, title: String? = nil) {
        self.url = url
        self.title = title
    }
}
