import Foundation

// API Version 7
public struct QuoteApproval: Codable, Equatable, Sendable {
    /// Describes who is expected to be able to quote that status and have the quote automatically authorized. An empty list means that nobody is expected to be able to quote this post.
    public let automatic: [NonFrozenEnum<QuoteApprovalPolicy>]
    /// Describes who is expected to have their quotes of this status be manually reviewed by the author before being accepted. An empty list means that nobody is expected to be able to quote this post.
    public var manual: [NonFrozenEnum<QuoteApprovalPolicy>]
    /// Describes how this status’ quote policy applies to the current user.
    public var currentUser: QuoteApprovalEntitlement
}

// API Version 7
public enum QuoteApprovalPolicy: String, Codable, Equatable, Sendable {
    case `public`
    case followers
    case following
}

// API Version 7
public enum QuoteApprovalEntitlement: String, Codable, Equatable, Sendable {
    case automatic
    case manual
    case denied
    case unknown
}
