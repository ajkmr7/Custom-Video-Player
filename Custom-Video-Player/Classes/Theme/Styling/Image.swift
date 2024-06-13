import UIKit

enum VideoPlayerImage: String, CaseIterable, NameableAsset {
    case backButton = "back_button"
    case forwardButton = "forward_button"
    case moreButton = "more_button"
    case pauseButton = "pause_button"
    case playButton = "play_button"
    case replayButton = "replay_button"
    case rewindButton = "rewind_button"
    case subtitlesButton = "subtitles_button"
    case watchPartyButton = "watchparty_button"
    case leaveButton = "leave_button"
    case participantsButton = "participants_button"
    case copyLinkButton = "copylink_button"

    var uiImage: UIImage { UIImage(self, resourceBundle: CustomVideoPlayer.resourceBundle) }
}
