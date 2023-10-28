struct WatchPartyConfig {
    var partyID: String?
    var userID: String?
    var partyLink: String?
    
    init(partyID: String? = nil, userID: String? = nil, partyLink: String? = nil) {
        self.partyID = partyID
        self.userID = userID
        self.partyLink = partyLink
    }
}
