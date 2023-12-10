import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/statuses/#pin
public struct PostV1StatusesPin: AuthorizationRequest {
    public typealias Response = Status

    public init(statusID: String, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = statusID
    }
    public var authorization: Authorization
    public let statusID: String
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/statuses/\(statusID)/pin" }
}
