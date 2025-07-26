import Foundation

public struct EmojiReaction: Codable, Sendable {
    public let name: String
    public let count: Int
    public let accountIds: [Account.ID]?
    public let me: Bool

    // ondemand resource emoji
    public let url: URL?
    public let staticUrl: URL?
    public let domain: String?
    public let width: Int?
    public let height: Int?
}