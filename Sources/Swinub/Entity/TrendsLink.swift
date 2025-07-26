import Foundation

public struct TrendsLink: Codable, Sendable {
    public let url: URL
    public let title: String
    public let description: String
    public let type: String
    public let authorName: String?
    public let authorUrl: String?
    public let providerName: String?
    public let providerUrl: String?
    public let html: String?
    public let width: Int?
    public let height: Int?
    public let image: URL?
    public let embedUrl: String?
    public let blurhash: String?
    public let history: [TrendsLinkHistory]
}

public struct TrendsLinkHistory: Codable, Sendable {
    /// UNIX timestamp
    public let day: String
    public let accounts: String
    public let uses: String
}