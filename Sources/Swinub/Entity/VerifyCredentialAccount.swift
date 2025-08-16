import Foundation

// Response model for /api/v1/accounts/verify_credentials
public struct VerifyCredentialAccount: Codable, Identifiable, Sendable {
    public let id: Account.ID
    public let username: String
    public let acct: String
    public var url: URL?
    public let displayName: String
    public let locked: Bool
    public let bot: Bool
    public let discoverable: Bool?
    public let group: Bool?
    public let createdAt: Date
    public let note: String

    public var avatar: URL?
    public var avatarStatic: URL?
    public var header: URL?
    public var headerStatic: URL?

    public let followersCount: Int
    public let followingCount: Int
    public let statusesCount: Int
    // ISO 8601 Date string like "2024-09-06"
    public let lastStatusAt: String?
    public let noindex: Bool?

    public let source: Source?
    public let emojis: [CustomEmoji]
    public let roles: [Role]?
    public let fields: [AccountField]
    public let role: Role?

    public struct Source: Codable, Sendable {
        public let privacy: String?
        public let sensitive: Bool?
        public let language: String?
        public let note: String?
        public let fields: [AccountField]?
        public let followRequestsCount: Int?
    }

    public struct Role: Codable, Sendable {
        public let id: String
        public let name: String
        public let permissions: String
        public let color: String
        public let highlighted: Bool
    }
}

