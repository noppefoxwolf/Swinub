import Foundation

public struct StatusApplication: Codable, Sendable {
    public let name: String
    public let website: URL?
}