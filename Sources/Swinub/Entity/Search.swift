public struct Search: Codable, Sendable {
    public let accounts: [Account]
    public let statuses: [Status]
    public let hashtags: [Tag]
}
