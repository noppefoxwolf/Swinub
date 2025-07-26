import Foundation

// firefishの拡張
public struct Reaction: Sendable, Codable {
    public let count: Int
    public let me: Bool
    public let name: String
    public let url: URL?
    public let staticURL: URL?
}