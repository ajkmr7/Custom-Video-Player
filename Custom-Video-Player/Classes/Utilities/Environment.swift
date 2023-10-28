struct Environment {
    static let shared = Environment()
    
    private let urlScheme = "custom-video-player"
    
    func getWatchPartyDeeplink(_ partyID: String) -> String {
        return "\(urlScheme)://video/watch_party/join?party_id=\(partyID)"
    }
}
