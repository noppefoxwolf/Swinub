public struct Authorization: Sendable {
    public init(host: String, accountID: String, oauthToken: String) {
        self.host = host
        self.accountID = accountID
        self.oauthToken = oauthToken
    }

    public let host: String
    public let accountID: String
    public let oauthToken: String
}
