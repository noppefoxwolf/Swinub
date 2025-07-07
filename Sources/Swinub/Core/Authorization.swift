public struct Authorization: Sendable {
    public init(host: String, accountID: Account.ID, oauthToken: String, userAgent: String = "dev.noppe.Swinub") {
        self.host = host
        self.accountID = accountID
        self.oauthToken = oauthToken
        self.userAgent = userAgent
    }

    public let host: String
    public let accountID: Account.ID
    public let oauthToken: String
    public let userAgent: String
}
