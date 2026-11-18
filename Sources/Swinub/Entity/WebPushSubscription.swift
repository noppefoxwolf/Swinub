public struct WebPushSubscription: Codable, Sendable {
    public struct Alerts: Codable, Sendable {
        public let follow: Bool?
        public let followRequest: Bool?
        public let favourite: Bool?
        public let reblog: Bool?
        public let mention: Bool?
        public let poll: Bool?
        /// Fedibird extension for emoji reaction notifications.
        public let emojiReaction: Bool?
        /// Fedibird extension for post reference notifications.
        public let statusReference: Bool?
        public let status: Bool?
        public let update: Bool?
        public let quote: Bool?
        public let quotedUpdate: Bool?
        public let severedRelationships: Bool?
        public let moderationWarning: Bool?
        public let annualReport: Bool?
        public let adminSignUp: Bool?
        public let adminReport: Bool?
        public let addedToCollection: Bool?
        public let collectionUpdate: Bool?

        enum CodingKeys: String, CodingKey {
            case mention
            case reblog
            case follow
            case followRequest
            case favourite
            case poll
            case emojiReaction
            case statusReference
            case status
            case update
            case quote
            case quotedUpdate
            case severedRelationships
            case moderationWarning
            case annualReport
            case adminSignUp = "admin.signUp"
            case adminReport = "admin.report"
            case addedToCollection
            case collectionUpdate
        }
    }

    public enum ID: Codable, Sendable {
        case int(Int)
        case string(String)

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                let intValue = try container.decode(Int.self)
                self = .int(intValue)
            } catch is Swift.DecodingError {
                let stringValue = try container.decode(String.self)
                self = .string(stringValue)
            } catch {
                throw error
            }
        }

        enum CodingKeys: CodingKey {
            case int
            case string
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .int(let value):
                try container.encode(value)
            case .string(let value):
                try container.encode(value)
            }
        }
    }

    public let id: ID
    public let endpoint: String
    public let alerts: Alerts?
    public let serverKey: String
}
