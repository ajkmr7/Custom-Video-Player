import AVKit
import SnapKit
import UIKit

extension VideoPlayerViewController: PlayerControlsViewDelegate {
    func goBack() {
        coordinator.navigationController.dismiss(animated: true)
    }
    
    func switchSubtitles() {
        
    }
    
    func openSettings() {
        
    }
    
    func seekBackward() {
        guard let player = player,
              let seekToTime = viewModel.getBackwardTime(currentTime: player.currentTime())
        else {
            return
        }
        player.seek(to: seekToTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { [weak self] _ in
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
        player.seek(to: seekToTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { [weak self] _ in
            guard let self = self else { return }
            guard let currentTime = player.currentItem?.currentTime() else { return }
            self.playerControlsView.seekBarValue = Float(currentTime.seconds)
            self.playerControlsView.currentTimeLabelText = currentTime.durationText + "/"
        }
    }
    
    func sliderValueChanged(slider: UISlider, event: UIEvent) {
        var pauseTime: CMTime = kCMTimeZero
        guard let player = player else { return }
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                player.pause()
                guard let currentTime = player.currentItem?.currentTime() else { return }
                pauseTime = currentTime
            case .moved:
                break
            case .ended:
                let seekingCM = CMTimeMake(Int64(slider.value * Float(pauseTime.timescale)), pauseTime.timescale)
                player.seek(to: seekingCM)
                /// Retain video player state on seeking: whenever user interacts with seek bar, we pause the player internally in order to calculate the new time. So, once the seek bar action is completed we would need to retain the original playback state of the player.
                viewModel.playerState == .play ? player.play() : player.pause()
            default:
                break
            }
        }
    }
}
