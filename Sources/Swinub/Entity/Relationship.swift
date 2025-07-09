//https://docs.joinmastodon.org/entities/Relationship/
public struct Relationship: Codable, Identifiable, Sendable {
    /// The account ID.
    public let id: ID
    public let following: Bool
    public let followedBy: Bool
    public let blocking: Bool
    public let blockedBy: Bool
    public let muting: Bool
    public let requested: Bool

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
