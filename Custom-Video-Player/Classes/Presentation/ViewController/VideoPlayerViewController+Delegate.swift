import AVKit
import SnapKit
import UIKit

// MARK: - Player Control Actions

extension VideoPlayerViewController: PlayerControlsViewDelegate {
    func goBack() {
        coordinator.navigationController.dismiss(animated: true)
    }
    
    func switchSubtitles() {
        invalidateControlsHiddenTimer()
        pausePlayer()
        guard let subtitleSelectionView = subtitleSelectionView else { return }
        coordinator.navigationController.presentedViewController?.present(subtitleSelectionView, animated: true)
    }
    
    func openSettings() {
        // TODO: Implement settings functionality
    }
    
    func seekBackward() {
        guard let player = player,
              let seekToTime = viewModel.getBackwardTime(currentTime: player.currentTime())
        else {
            return
        }
        player.seek(to: seekToTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { [weak self] _ in
            guard let self = self else { return }
            guard let currentTime = player.currentItem?.currentTime() else { return }
            self.playerControlsView.seekBarValue = Float(currentTime.seconds)
            self.playerControlsView.currentTimeLabelText = currentTime.durationText + "/"
        }
    }
    
    func togglePlayPause() {
        switch viewModel.playerState {
        case .play:
            pausePlayer()
        case .pause:
            resumePlayer()
        }
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
