import AVFoundation
import FirebaseDatabase

enum PlayerState {
    case play
    case pause
}

protocol WatchPartyDelegate: AnyObject {
    func onWatchPartyEntered()
    func onWatchPartyExited()
    func onWatchPartyEnded()
    func onPlayerStateUpdated()
    func onCurrentTimeUpdated(_ currentTimeDurationText: String, _ currentTimeInSeconds: Float)
    func onParticipantsUpdated()
}

public class VideoPlayerViewModel {
    private let seekDuration: Float64 = 15
    var playerState: PlayerState = .pause
    var videoPlayerConfig: VideoPlayerConfig
    var watchPartyConfig: WatchPartyConfig?
    var ref: DatabaseReference
    weak var watchPartyDelegate: WatchPartyDelegate?
    
    var url: URL? {
        guard let videos = videoPlayerConfig.playlist.videos, videos.count > 0, let url = videos[videoPlayerConfig.playlist.currentVideoIndex ?? 0].url else { return nil }
        return URL(string: url)
    }
    
    var titleLabelText: String {
        return videoPlayerConfig.playlist.title
    }
    
    var subtitleLabelText: String? {
        guard let videos = videoPlayerConfig.playlist.videos, videos.count > 0, let title = videos[videoPlayerConfig.playlist.currentVideoIndex ?? 0].title else { return nil }
        return title
    }
    
    public init(videoPlayerConfig: VideoPlayerConfig, partyID: String? = nil, chatName: String? = nil) {
        self.videoPlayerConfig = videoPlayerConfig
        self.watchPartyConfig = WatchPartyConfig(partyID: partyID)
        self.ref = Database.database().reference()
        if let chatName = chatName {
            self.joinParty(for: chatName)
        }
    }
    
    func getForwardTime(currentTime: CMTime, duration: CMTime) -> CMTime? {
        let playerCurrentTime = CMTimeGetSeconds(currentTime)
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < CMTimeGetSeconds(duration) {
            return CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        }
        return CMTimeMake(value: Int64(CMTimeGetSeconds(duration) * 1000 as Float64), timescale: 1000)
    }
    
    func getBackwardTime(currentTime: CMTime) -> CMTime? {
        let playerCurrentTime = CMTimeGetSeconds(currentTime)
        var newTime = playerCurrentTime - seekDuration
        
        if newTime < 0 {
            newTime = 0
        }
        return CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
    }
    
    func getFormattedTime(totalDuration: Double) -> String {
        let hours = Int(totalDuration.truncatingRemainder(dividingBy: 86400) / 3600)
        let minutes = Int(totalDuration.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(totalDuration.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        }
        return String(format: "%02i:%02i", minutes, seconds)
    }
}

extension VideoPlayerViewModel {
    func hostParty(for host: String, currentTime: CMTime?) {
        watchPartyConfig?.partyID = RandomUUIDGenerator.generateRandomUUID(length: 6)
        watchPartyConfig?.userID = RandomUUIDGenerator.generateRandomUUID(length: 12)
        watchPartyConfig?.isHost = true
        if let partyID = watchPartyConfig?.partyID {
            watchPartyConfig?.partyLink = Environment.shared.getWatchPartyDeeplink(partyID)
        }
        guard let partyID = watchPartyConfig?.partyID, let userID = watchPartyConfig?.userID, let partyLink = watchPartyConfig?.partyLink, let videoURL = url?.description, let subtitleLabelText = subtitleLabelText, let currentTime = currentTime else { return }
        setupWatchPartyObservers()
        watchPartyDelegate?.onWatchPartyEntered()
        self.ref.child("parties").child(partyID).setValue([
            "partyLink": partyLink,
            "participants": [
                userID : [
                    "username": "\(host)",
                    "type": "Host"
                ]
            ],
            "videoSetting": [
                "isPlaying": playerState == .play,
                "currentTimeDurationText": currentTime.durationText,
                "currentTimeInSeconds": currentTime.seconds,
                "url": videoURL,
                "title": titleLabelText,
                "subtitle": subtitleLabelText
            ]
        ])
    }
    
    func joinParty(for participant: String) {
        watchPartyConfig?.userID = RandomUUIDGenerator.generateRandomUUID(length: 12)
        watchPartyConfig?.isHost = false
        guard let partyID = watchPartyConfig?.partyID, let userID = watchPartyConfig?.userID else { return }
        setupWatchPartyObservers()
        let newParticipant: [String: String] = [
            "username": participant,
            "type": "Participant"
        ]
        let participantsRef = self.ref.child("parties").child(partyID).child("participants")
        let childUpdates = [userID: newParticipant]
        participantsRef.updateChildValues(childUpdates)
    }

    func leaveParty() {
        guard let partyID = watchPartyConfig?.partyID, let userID = watchPartyConfig?.userID else { return }

        self.ref.child("parties").child(partyID).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self,
                  let roomData = snapshot.value as? [String: Any],
                  let participants = roomData["participants"] as? [String: [String: Any]] else {
                return
            }
            
            self.watchPartyDelegate?.onWatchPartyExited()
            
            if participants.first(where: { $0.value["type"] as? String == "Host" && $0.key == userID }) != nil {
                self.ref.child("parties").child(partyID).removeValue()
            } else {
                var updatedParticipants: [String: [String: Any]] = participants
                updatedParticipants.removeValue(forKey: userID)
                self.ref.child("parties").child(partyID).child("participants").setValue(updatedParticipants)
            }
        }
    }
    
    func fetchParticipants(completion: @escaping ([String]?) -> Void) {
        guard let partyID = watchPartyConfig?.partyID else {
            completion(nil)
            return
        }
        
        self.ref.child("parties").child(partyID).child("participants").observeSingleEvent(of: .value) { (snapshot) in
            guard let participantsData = snapshot.value as? [String: [String: Any]] else {
                completion(nil)
                return
            }
            
            let participantUsernames = participantsData.values.compactMap { participant -> String? in
                guard let username = participant["username"] as? String else {
                    return nil
                }
                return username
            }
            
            completion(participantUsernames)
        }
    }
}

// MARK: - Watch Party State Updations through observers

extension VideoPlayerViewModel {
    func updatePlayerState() {
        guard let partyID = watchPartyConfig?.partyID else { return }
        let videoSettingRef = self.ref.child("parties").child(partyID).child("videoSetting")
        let childUpdates = ["isPlaying": playerState == .play]
        videoSettingRef.updateChildValues(childUpdates)
    }
    
    func updateCurrentTime(_ currentTimeDurationText: String, _ currentTimeInSeconds: Float) {
        guard let partyID = watchPartyConfig?.partyID else { return }
        let videoSettingRef = self.ref.child("parties").child(partyID).child("videoSetting")
        let currentTimeDurationTextUpdates = ["currentTimeDurationText": currentTimeDurationText]
        let currentTimeInSecondsUpdates = ["currentTimeInSeconds": currentTimeInSeconds]
        videoSettingRef.updateChildValues(currentTimeDurationTextUpdates)
        videoSettingRef.updateChildValues(currentTimeInSecondsUpdates)
    }
    
    func setupWatchPartyObservers() {
        setupPartyObserver()
        setupPlayerStateObserver()
        setupCurrentTimeObserver()
        setupParticipantsObserver()
    }
    
    private func setupPartyObserver() {
        guard let partyID = watchPartyConfig?.partyID else { return }
        let partiesRef = self.ref.child("parties")

        partiesRef.observe(.value, with: { [weak self] snapshot in
            if !snapshot.hasChild(partyID), let isHost = self?.watchPartyConfig?.isHost, !isHost {
                self?.watchPartyDelegate?.onWatchPartyEnded()
            }
        })
    }
    
    private func setupPlayerStateObserver() {
        guard let partyID = watchPartyConfig?.partyID else { return }
        ref.child("parties").child(partyID).child("videoSetting").observe(.value) { [weak self] (snapshot) in
            if let value = snapshot.value as? [String: Any],
               let isPlaying = value["isPlaying"] as? Bool {
                if isPlaying && self?.playerState == .pause {
                    self?.watchPartyDelegate?.onPlayerStateUpdated()
                } else if !isPlaying && self?.playerState == .play {
                    self?.watchPartyDelegate?.onPlayerStateUpdated()
                }
            }
        }
    }
    
    private func setupCurrentTimeObserver() {
        guard let partyID = watchPartyConfig?.partyID else { return }
        ref.child("parties").child(partyID).child("videoSetting").observe(.value) { [weak self] (snapshot) in
            if let value = snapshot.value as? [String: Any],
               let currentTimeDurationText = value["currentTimeDurationText"] as? String,
               let currentTimeInSeconds = value["currentTimeInSeconds"] as? Float {
                self?.watchPartyDelegate?.onCurrentTimeUpdated(currentTimeDurationText, currentTimeInSeconds)
            }
        }
    }
    
    private func setupParticipantsObserver() {
        guard let partyID = watchPartyConfig?.partyID else { return }
        ref.child("parties").child(partyID).child("participants").observe(.value) { [weak self] (snapshot) in
            if snapshot.value is [String: Any] {
                self?.watchPartyDelegate?.onParticipantsUpdated()
            }
        }
    }
}
