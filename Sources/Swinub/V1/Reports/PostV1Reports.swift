import Foundation
import HTTPTypes

public struct Report: Codable, Identifiable {
    public let id: ID
    
    public struct ID: Equatable, Hashable, Sendable, Codable {
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
    }
}

public struct PostV1Reports: AuthorizationRequest {
    public typealias Response = Report

    public init(accountID: String, authorization: Authorization) {
        self.authorization = authorization
        self.accountID = accountID
    }
    public var authorization: Authorization
    public let accountID: String
    public var comment: String = ""
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/reports" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "account_id": accountID,
            "comment": comment,
        ]
    }
}
