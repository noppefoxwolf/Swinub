import Foundation
import HTTPTypes

public struct GetV1FollowRequests: HTTPEndpointRequest, Sendable {
    public typealias Response = [Account]
    
    public init(authorization: Authorization, maxID: String? = nil, sinceID: String? = nil, limit: Int? = nil) {
        self.authorization = authorization
        self.maxID = maxID
        self.sinceID = sinceID
        self.limit = limit
    }
    
    public var byAccountID: Account.ID { authorization.accountID }
    public let authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/follow_requests" }
    public let method: HTTPRequest.Method = .get
    
    public let maxID: String?
    public let sinceID: String?
    public let limit: Int?
    
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "max_id": maxID,
            "since_id": sinceID,
            "limit": limit
        ]
    }
}