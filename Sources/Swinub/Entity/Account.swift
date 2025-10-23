import Foundation

// https://docs.joinmastodon.org/entities/Account/#avatar
public struct Account: Codable, Identifiable, Sendable {
    public let id: ID
    public let username: String
    public let acct: String
    public var url: URL?
    public let displayName: String
    public let note: String
    public var avatar: URL?
    public var header: URL?
    public let fields: [AccountField]
    public let emojis: [CustomEmoji]
    public let createdAt: Date
    // ISO 8601 Date
    public let lastStatusAt: String?
    public let statusesCount: Int
    public let followersCount: Int
    public let followingCount: Int
    public let subscribingCount: Int?

    public let bot: Bool
    public let locked: Bool

    public struct ID: Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
        public let rawValue: String
        public var description: String { rawValue }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.rawValue = try container.decode(String.self)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }
}

public struct AccountField: Codable, Sendable {
    public let name: String
    public let value: String
    public let verifiedAt: Date?
}
