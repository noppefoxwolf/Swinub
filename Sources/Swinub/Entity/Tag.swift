import Foundation

public struct Tag: Codable, Sendable {
    public let name: String
    public var url: URL?
    public let history: [TagHistory]
    public let following: Bool?
}

public struct TagHistory: Codable, Sendable {
    // UNIX timestamp
    public let day: String
    public let accounts: String
    public let uses: String
}
