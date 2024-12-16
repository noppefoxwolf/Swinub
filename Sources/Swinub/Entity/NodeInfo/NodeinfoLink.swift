// https://github.com/jhass/nodeinfo/blob/main/PROTOCOL.md

public import Foundation

public struct NodeinfoLink: Codable, Sendable {
    public let rel: Relationship
    public let href: URL
    
    public struct Relationship: Codable, Sendable, Equatable, Comparable {
        public let rawValue: String
        
        public init(from decoder: any Decoder) throws {
            rawValue = try decoder.singleValueContainer().decode(String.self)
        }
        
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static let v10 = Self(rawValue: "http://nodeinfo.diaspora.software/ns/schema/1.0")
        public static let v11 = Self(rawValue: "http://nodeinfo.diaspora.software/ns/schema/1.1")
        public static let v20 = Self(rawValue: "http://nodeinfo.diaspora.software/ns/schema/2.0")
        public static let v21 = Self(rawValue: "http://nodeinfo.diaspora.software/ns/schema/2.1")
        
        public static func < (lhs: NodeinfoLink.Relationship, rhs: NodeinfoLink.Relationship) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

