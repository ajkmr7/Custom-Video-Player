struct WatchPartyConfig {
    var partyID: String?
    var userID: String?
    var partyLink: String?
    var isHost: Bool?
    
    init(partyID: String? = nil, userID: String? = nil, partyLink: String? = nil, isHost: Bool? = nil) {
        self.partyID = partyID
        self.userID = userID
        self.partyLink = partyLink
        self.isHost = isHost
    }
}
