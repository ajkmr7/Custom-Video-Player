import UIKit
import SnapKit
import Custom_Video_Player

enum Deeplink: String {
    case play /// custom-video-player://video/play?id=<video_id>
    case watchParty = "watch_party"/// custom-video-player://video/watch_party/join?=<party_id>
}

extension ViewController {
    func handleDeeplink(_ deeplink: Deeplink, url: URL) {
        switch deeplink {
        case .play:
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
               components.host == "video",
               let queryItems = components.queryItems {
                for queryItem in queryItems {
                    if queryItem.name == "id", let _ = queryItem.value {
                        navigatoToVideoPlayer()
                    }
                }
            }
        case .watchParty:
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
               components.host == "video",
               components.path == "/watch_party/join",
               let queryItems = components.queryItems {
                for queryItem in queryItems {
                    if queryItem.name == "party_id", let partyID = queryItem.value {
                        viewModel?.partyID = partyID
                        setupJoinWatchPartyAlertView()
                        if let joinWatchPartyAlert = joinWatchPartyAlert {
                            navigationController?.present(joinWatchPartyAlert, animated: true)
                        }
                    }
                }
            }
        }
    }
}
