import Foundation

// API Version 7
public struct QuoteApproval: Codable, Equatable, Sendable {
    /// Describes who is expected to be able to quote that status and have the quote automatically authorized. An empty list means that nobody is expected to be able to quote this post.
    public let automatic: [QuoteApprovalPolicy]
    /// Describes who is expected to have their quotes of this status be manually reviewed by the author before being accepted. An empty list means that nobody is expected to be able to quote this post.
    public var manual: [QuoteApprovalPolicy]
    /// Describes how this status’ quote policy applies to the current user.
    public var currentUser: QuoteApprovalEntitlement
}

// API Version 7
public struct QuoteApprovalPolicy: RawRepresentable, Codable, Equatable, Sendable {
    public let rawValue: String
    
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
    
    public static var `public`: Self { .init(rawValue: "public") }
    public static var followers: Self { .init(rawValue: "followers") }
    public static var following: Self { .init(rawValue: "following") }
}

// API Version 7
public struct QuoteApprovalEntitlement: RawRepresentable, Codable, Equatable, Sendable {
    public let rawValue: String
    
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
    
    public static var automatic: Self { .init(rawValue: "automatic") }
    public static var manual: Self { .init(rawValue: "manual") }
    public static var denied: Self { .init(rawValue: "denied") }
    public static var unknown: Self { .init(rawValue: "unknown") }
}
