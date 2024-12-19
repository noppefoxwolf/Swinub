import Foundation

public struct Filter: Codable, Identifiable, Hashable, Sendable {
    public let id: ID
    public let title: String
    public let context: [FilterContext]
    public let expiresAt: Date?
    public let filterAction: FilterAction
    public let keywords: [FilterKeyword]?
    public let statuses: [FilterStatus]?
    
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
