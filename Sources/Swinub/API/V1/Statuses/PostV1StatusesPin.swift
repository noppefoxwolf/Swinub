import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/statuses/#pin
public struct PostV1StatusesPin: HTTPEndpointRequest, Sendable {
    public typealias Response = Status

    public init(statusID: Status.ID, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = statusID
    }
    public var authorization: Authorization
    public let statusID: Status.ID
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/statuses/\(statusID)/pin" }
}
