import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/statuses/#boost
public struct PostV1StatusesReblog: HTTPEndpointRequest, Sendable {
    public typealias Response = Status

    public init(id: Status.ID, visibility: StatusVisibility, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = id
        self.visibility = visibility
    }
    public let authorization: Authorization
    public let statusID: Status.ID
    public let visibility: StatusVisibility
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/statuses/\(statusID)/reblog" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "visibility": visibility.rawValue
        ]
    }
}
