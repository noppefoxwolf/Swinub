import Foundation

public struct Report: Codable, Identifiable, Sendable {
    public let id: ID
    public let actionTaken: Bool?
    public let actionTakenAt: Date?
    public let category: String?
    public let comment: String?
    public let forwarded: Bool?
    public let createdAt: Date?
    public let statusIds: [Status.ID]?
    public let ruleIds: [String]?
    public let collectionIds: [String]?
    public let targetAccount: Account?

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
