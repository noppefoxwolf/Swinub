import Foundation

// https://docs.joinmastodon.org/entities/Notification/
public struct Notification: Codable, Identifiable, Sendable {
    public let id: ID
    public let type: Kind
    public let createdAt: Date
    public let account: Account
    public let status: Status?
    public let groupKey: String?
    public let filtered: Bool?
    public let report: Report?
    public let event: RelationshipSeveranceEvent?
    public let moderationWarning: ModerationWarning?
    public let collection: Collection?
    public let fallback: Fallback?

    // fedibird
    public let emojiReaction: EmojiReaction?

    /// A notification type. Compatible servers can return additional values.
    public struct Kind: RawRepresentable, Codable, Hashable, Sendable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let mention = Self(rawValue: "mention")
        public static let status = Self(rawValue: "status")
        public static let reblog = Self(rawValue: "reblog")
        public static let follow = Self(rawValue: "follow")
        public static let followRequest = Self(rawValue: "follow_request")
        public static let favourite = Self(rawValue: "favourite")
        public static let poll = Self(rawValue: "poll")
        public static let update = Self(rawValue: "update")
        public static let severedRelationships = Self(rawValue: "severed_relationships")
        public static let moderationWarning = Self(rawValue: "moderation_warning")
        public static let annualReport = Self(rawValue: "annual_report")
        public static let adminSignUp = Self(rawValue: "admin.sign_up")
        public static let adminReport = Self(rawValue: "admin.report")
        public static let quote = Self(rawValue: "quote")
        public static let quotedUpdate = Self(rawValue: "quoted_update")
        public static let addedToCollection = Self(rawValue: "added_to_collection")
        public static let collectionUpdate = Self(rawValue: "collection_update")

        // Fedibird extensions
        public static let emojiReaction = Self(rawValue: "emoji_reaction")
        public static let statusReference = Self(rawValue: "status_reference")
        public static let scheduledStatus = Self(rawValue: "scheduled_status")
        public static let followed = Self(rawValue: "followed")
    }

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
