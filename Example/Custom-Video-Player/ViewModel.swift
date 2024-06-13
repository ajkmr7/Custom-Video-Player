import FirebaseDatabase
import CustomVideoPlayer

class ViewModel {
    var ref: DatabaseReference
    var partyID: String?
    
    public init() {
        self.ref = Database.database().reference()
    }
    
    func fetchVideoPlayerConfig(for partyID: String, completion: @escaping (VideoPlayerConfig?) -> Void) {
        self.ref.child("parties").child(partyID).child("videoSetting").observeSingleEvent(of: .value) { (snapshot) in
            guard let videoSetting = snapshot.value as? [String: Any],
                  let title = videoSetting["title"] as? String,
                  let url = videoSetting["url"] as? String,
                  let subtitle = videoSetting["subtitle"] as? String else {
                completion(nil)
                return
            }

            let videoPlayerConfig = VideoPlayerConfig(
                playlist: VideoPlaylist(
                    title: title,
                    videos: [
                        Video(
                            url: url,
                            title: subtitle
                        )
                    ]
                )
            )

            completion(videoPlayerConfig)
        }
    }
}
