import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/statuses/#boost
public struct PostV1StatusesReblog: AuthorizationRequest {
    public typealias Response = Status

    public init(id: String, visibility: String, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = id
        self.visibility = visibility
    }
    public let authorization: Authorization
    public let statusID: String
    public let visibility: String
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/statuses/\(statusID)/reblog" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "visibility": visibility
        ]
    }
}
