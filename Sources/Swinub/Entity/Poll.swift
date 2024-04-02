import Foundation

public struct Poll: Codable, Identifiable, Sendable {
    public let id: ID
    public let expiresAt: Date?
    public let expired: Bool
    public let multiple: Bool
    public let votesCount: Int
    public let votersCount: Int?
    public let options: [PollOption]
    public let emojis: [CustomEmoji]
    public let voted: Bool?
    public let ownVotes: [Int]?
    
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

public struct PollOption: Codable, Sendable {
    public let title: String
    public let votesCount: Int?
}
