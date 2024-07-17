public struct WebPushSubscription: Codable, Sendable {
    public struct Alerts: Codable, Sendable {
        public let follow: Bool?
        public let favourite: Bool?
        public let reblog: Bool?
        public let mention: Bool?
        public let poll: Bool?
        public let emojiReaction: Bool?
    }

    public let id: String
    public let endpoint: String
    public let alerts: Alerts?
    public let serverKey: String
}
