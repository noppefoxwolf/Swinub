public struct Authorization: Sendable {
    public init(host: String, accountID: Account.ID, oauthToken: String) {
        self.host = host
        self.accountID = accountID
        self.oauthToken = oauthToken
    }

    public let host: String
    public let accountID: Account.ID
    public let oauthToken: String
}
