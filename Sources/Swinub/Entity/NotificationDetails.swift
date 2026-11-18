import Foundation

extension Notification {
    public struct RelationshipSeveranceEvent: Codable, Identifiable, Sendable {
        public let id: String
        public let type: String
        public let purged: Bool
        public let targetName: String
        public let followersCount: Int
        public let followingCount: Int
        public let createdAt: Date
    }

    public struct ModerationWarning: Codable, Identifiable, Sendable {
        public let id: String
        public let action: String
        public let text: String
        public let statusIds: [Status.ID]?
        public let createdAt: Date
        public let targetAccount: Account?
        public let appeal: Appeal?

        public struct Appeal: Codable, Sendable {
            public let text: String
            public let state: String
        }
    }

    public struct Collection: Codable, Identifiable, Sendable {
        public let id: String
        public let uri: URL
        public let name: String
        public let description: String?
        public let language: String?
        public let accountId: Account.ID
        public let local: Bool
        public let sensitive: Bool
        public let discoverable: Bool
        public let url: URL?
        public let itemCount: Int
        public let createdAt: Date
        public let updatedAt: Date
        public let tag: Tag?
        public let items: [Item]

        public struct Tag: Codable, Sendable {
            public let name: String
            public let url: URL
        }

        public struct Item: Codable, Identifiable, Sendable {
            public let id: String
            public let state: String
            public let createdAt: Date
            public let accountId: Account.ID?
        }
    }

    /// The server may include HTML in these display strings.
    public struct Fallback: Codable, Sendable {
        public let title: String
        public let summary: String?
        public let description: String?
    }
}
