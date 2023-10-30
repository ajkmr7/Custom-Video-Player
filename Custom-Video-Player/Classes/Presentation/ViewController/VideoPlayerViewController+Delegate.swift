import AVKit
import SnapKit
import UIKit

// MARK: - Player Control Actions

extension VideoPlayerViewController: PlayerControlsViewDelegate {
    func goBack() {
        coordinator.navigationController.dismiss(animated: true)
    }
    
    func showParticipants() {
        viewModel.fetchParticipants { [weak self] participants in
            guard let participants = participants else { return }
            self?.setupParticipantsView(with: participants)
            guard let participantsView = self?.participantsView else { return }
            self?.coordinator.navigationController.presentedViewController?.present(participantsView, animated: true)
        }
    }
    
    func copyLink() {
        playerControlsView.displayPlayerNotification(style: .success, message: "Party link has been successfully copied 🎉")
        UIPasteboard.general.string = viewModel.watchPartyConfig?.partyLink
    }
    
    func switchSubtitles() {
        guard let subtitleSelectionView = subtitleSelectionView else { return }
        coordinator.navigationController.presentedViewController?.present(subtitleSelectionView, animated: true)
    }
    
    func hostWatchParty() {
        coordinator.navigationController.presentedViewController?.present(hostWatchPartyAlert, animated: true, completion: nil)
    }
    
    func leaveWatchParty() {
        coordinator.navigationController.presentedViewController?.present(leaveWatchPartyAlert, animated: true, completion: nil)
    }
    
    func seekBackward() {
        guard let player = player,
              let seekToTime = viewModel.getBackwardTime(currentTime: player.currentTime())
        else {
            return
        }
        player.seek(to: seekToTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let self = self else { return }
            guard let currentTime = player.currentItem?.currentTime() else { return }
            self.playerControlsView.seekBarValue = Float(currentTime.seconds)
            self.playerControlsView.currentTimeLabelText = currentTime.durationText + "/"
            self.viewModel.updateCurrentTime(currentTime.durationText, Float(currentTime.seconds))
        }
    }
    
    func togglePlayPause() {
        switch viewModel.playerState {
        case .play:
            pausePlayer()
        case .pause:
            resumePlayer()
        }
        viewModel.updatePlayerState()
    }
    
    func seekForward() {
        guard let player = player,
              let duration = player.currentItem?.duration,
              let seekToTime = viewModel.getForwardTime(currentTime: player.currentTime(), duration: duration)
        else {
            return
        }
        player.seek(to: seekToTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { [weak self] _ in
            guard let self = self else { return }
            guard let currentTime = player.currentItem?.currentTime() else { return }
            self.playerControlsView.seekBarValue = Float(currentTime.seconds)
            self.playerControlsView.currentTimeLabelText = currentTime.durationText + "/"
            self.viewModel.updateCurrentTime(currentTime.durationText, Float(currentTime.seconds))
        }
    }
    
    func sliderValueChanged(slider: UISlider, event: UIEvent) {
        var pauseTime: CMTime = CMTime.zero
        guard let player = player else { return }
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                player.pause()
                guard let currentTime = player.currentItem?.currentTime() else { return }
                pauseTime = currentTime
                invalidateControlsHiddenTimer()
            case .moved:
                break
            case .ended:
                resetControlsHiddenTimer()
                let seekingCM = CMTimeMake(value: Int64(slider.value * Float(pauseTime.timescale)), timescale: pauseTime.timescale)
                player.seek(to: seekingCM)
                self.viewModel.updateCurrentTime(seekingCM.durationText, Float(seekingCM.seconds))
                /// Retain video player state on seeking: whenever the user interacts with the seek bar, we pause the player internally to calculate the new time. So, once the seek bar action is completed, we would need to retain the original playback state of the player.
                viewModel.playerState == .play ? player.play() : player.pause()
            default:
                break
            }
        }
    }
}

// MARK: - Subtitle Functionality

extension VideoPlayerViewController: SubtitleSelectionDelegate {
    func onSubtitleTrackSelected(subtitleTrack: AVMediaSelectionOption?) {
        guard let mediaSelectionGroup = playerItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return }
        playerItem?.select(subtitleTrack, in: mediaSelectionGroup)
    }
    
    func onDismissed() {
        resumePlayer()
        resetControlsHiddenTimer()
    }
}

// MARK: - Watch Party Functionality

extension VideoPlayerViewController: WatchPartyDelegate {
    func onWatchPartyEntered() {
        playerControlsView.unhideWatchPartyFeatureButtons()
        playerControlsView.watchPartyButton.isEnabled = false
        playerControlsView.backButton.setImage(VideoPlayerImage.leaveButton.uiImage, for: .normal)
        playerControlsView.backButton.removeTarget(playerControlsView.self,
                                                   action: #selector(playerControlsView.backButtonTap),
                                                   for: .touchUpInside)
        playerControlsView.backButton.addTarget(playerControlsView.self, action: #selector(playerControlsView.leaveWatchPartyButtonTap(_:)), for: .touchUpInside)
    }
    
    func onWatchPartyExited() {
        viewModel.watchPartyConfig = nil
        pausePlayer()
        goBack()
    }
    
    func onWatchPartyEnded() {
        viewModel.watchPartyConfig = nil
        pausePlayer()
        coordinator.navigationController.presentedViewController?.present(watchPartyEndedAlert, animated: true, completion: nil)
    }
    
    func onPlayerStateUpdated() {
        togglePlayPause()
    }
    
    func onCurrentTimeUpdated(_ currentTimeDurationText: String, _ currentTimeInSeconds: Float) {
        player?.seek(to: CMTimeMakeWithSeconds(Float64(currentTimeInSeconds), preferredTimescale: .max), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { [weak self] _ in
            guard let self = self else { return }
            guard let currentTime = self.player?.currentItem?.currentTime() else { return }
            self.playerControlsView.seekBarValue = Float(currentTime.seconds)
            self.playerControlsView.currentTimeLabelText = currentTime.durationText + "/"
        }
    }
    
    func onParticipantAdded(_ participantName: String) {
        onParticipantsUpdated()
        self.showControls()
        self.playerControlsView.displayPlayerNotification(style: .success, message: "\(participantName) has joined the party!")
    }
    
    func onParticipantRemoved(_ participantName: String) {
        onParticipantsUpdated()
        self.showControls()
        self.playerControlsView.displayPlayerNotification(style: .error, message:  "\(participantName) has left the party!")
    }
    
    func onParticipantsUpdated() {
        if let isHost = viewModel.watchPartyConfig?.isHost, isHost {
            guard let currentTime = player?.currentItem?.currentTime() else { return }
            viewModel.updateCurrentTime(currentTime.durationText, Float(currentTime.seconds))
        }
    }
}

