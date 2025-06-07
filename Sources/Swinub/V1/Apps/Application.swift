public struct Application: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let website: String?
    public let redirectUri: String
    public let clientId: String
    public let clientSecret: String
    public let vapidKey: String
}
