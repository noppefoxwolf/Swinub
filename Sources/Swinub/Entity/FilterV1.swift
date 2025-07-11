import Foundation

public struct FilterV1: Codable, Identifiable, Hashable, Sendable {
    public let id: ID
    public let phrase: String
    public let context: [FilterContextV1]
    public let expiresAt: Date?
    public let irreversible: Bool
    public let wholeWord: Bool

    public struct ID: Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
        public let rawValue: String
        public var description: String { rawValue }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.rawValue = try container.decode(String.self)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }
}
