import Foundation

//https://docs.joinmastodon.org/entities/Status/#content
public struct Status: Codable, Identifiable, Sendable {
    public let id: ID
    public let createdAt: Date
    public let account: Account
    public let content: String
    public let url: URL?
    public let inReplyToId: Status.ID?
    public let inReplyToAccountId: Account.ID?
    public let visibility: StatusVisibility

    // kmy.blue
    // https://github.com/kmycode/mastodon/wiki/ローカル公開API#既存のオブジェクトに追加されたプロパティ
    public let visibilityEx: StatusVisibility?
    public let sensitive: Bool
    public let spoilerText: String
    public let language: String?
    public let reblog: Indirect<Status>?
    // fedibird
    public let quote: Quote?
    public let poll: Poll?
    public let card: PreviewCard?
    public let mediaAttachments: [MediaAttachment]
    public let mentions: [Mention]
    public let application: StatusApplication?
    public let tags: [Status.Tag]
    public let emojis: [CustomEmoji]
    public let reblogsCount: Int
    public let favouritesCount: Int
    public let repliesCount: Int

    public let favourited: Bool?
    public let reblogged: Bool?
    public let muted: Bool?
    public let bookmarked: Bool?
    public let pinned: Bool?

    public let filtered: [FilterResult]?

    // fedibird, kmy.blue extensions
    public let emojiReactions: [EmojiReaction]?

    // Firefish extensions
    public let reactions: [Reaction]?

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


extension Status {
    public struct Tag: Codable, Sendable {
        public let name: String
        public let url: URL?
    }
}

extension Status {
    public struct Mention: Identifiable, Codable, Sendable {
        public let id: ID
        public let username: String
        public let url: URL?
        public let acct: String

        public struct ID: Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
            public let rawValue: String
            public var description: String { rawValue }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.singleValueContainer()
                self.rawValue = try container.decode(String.self)
            }
        }
    }
}

