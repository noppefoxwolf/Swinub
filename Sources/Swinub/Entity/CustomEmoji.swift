import Foundation

public struct CustomEmoji: Codable, Sendable {
    public let shortcode: String

    public let url: URL?

    public let staticUrl: URL?

    public let visibleInPicker: Bool
    public let category: String?

    // fedibird extensions
    public let width: Int?
    public let height: Int?
    public let aliases: [String]?
}