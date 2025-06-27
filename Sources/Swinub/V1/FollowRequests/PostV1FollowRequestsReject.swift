import Foundation
import HTTPTypes

public struct PostV1FollowRequestsReject: HTTPEndpointRequest, Sendable {
    public typealias Response = Relationship
    
    public init(accountID: Account.ID, authorization: Authorization) {
        self.accountID = accountID
        self.authorization = authorization
    }
    
    public let accountID: Account.ID
    public var byAccountID: Account.ID { authorization.accountID }
    public var authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/follow_requests/\(accountID)/reject" }
    public let method: HTTPRequest.Method = .post
}