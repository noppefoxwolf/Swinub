import Foundation

public struct FilterResult: Codable, Sendable {
    public let filter: Filter
    public let keywordMatches: [String]?
    public let statusMatches: [String]?
}