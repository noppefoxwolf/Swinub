import Foundation

// https://docs.joinmastodon.org/entities/Notification/
public struct Notification: Codable, Identifiable, Sendable {
    public let id: ID
    // workaround: fedibird.comでカスタムな通知タイプがある
    public let type: String
    public let createdAt: Date
    public let account: Account
    public let status: Status?

    // fedibird
    public let emojiReaction: EmojiReaction?

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
