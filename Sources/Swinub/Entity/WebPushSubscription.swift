public struct WebPushSubscription: Codable, Sendable {
    public struct Alerts: Codable, Sendable {
        public let follow: Bool?
        public let favourite: Bool?
        public let reblog: Bool?
        public let mention: Bool?
        public let poll: Bool?
        public let emojiReaction: Bool?
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
