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

public enum FilterContextV1: String, Codable, Sendable {
    case home
    case notifications
    case `public`
    case thread
    case account
}

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

public enum FilterContext: String, Codable, Hashable, CaseIterable, Sendable {
    case home
    case notifications
    case `public`
    case thread
    case account
}

public enum FilterAction: String, Codable, Hashable, Sendable {
    case warn
    case hide
}

public struct FilterKeyword: Codable, Hashable, Sendable {
    public let id: ID
    public let keyword: String
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

public struct FilterStatus: Codable, Hashable, Sendable {
    public let id: ID
    public let statusId: Status.ID
    
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
