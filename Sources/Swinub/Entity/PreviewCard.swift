import Foundation

public struct PreviewCard: Codable, Sendable {
    public var url: URL?
    public let title: String
    public let description: String
    public let type: PreviewCardType
    public let authorName: String
    public let authorUrl: String
    public let providerName: String
    public let providerUrl: String
    public let html: String
    public let width: Int
    public let height: Int
    public var image: URL?
    public let embedUrl: String
    public let blurhash: String?
}
