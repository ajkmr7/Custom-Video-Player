public enum VideoPlayerImage: String, CaseIterable, NameableAsset {
    case backButton = "back_button"
    case forwardButton = "forward_button"
    case moreButton = "more_button"
    case pauseButton = "pause_button"
    case playButton = "play_button"
    case replayButton = "replay_button"
    case rewindButton = "rewind_button"
    case subtitlesButton = "subtitles_button"

    var uiImage: UIImage { UIImage(self, resourceBundle: CustomVideoPlayer.resourceBundle) }
}
