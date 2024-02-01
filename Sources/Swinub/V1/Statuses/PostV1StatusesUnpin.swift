import Foundation
import HTTPTypes

public struct PostV1StatusesUnpin: AuthorizationRequest, Sendable {
    public typealias Response = Status

    public init(statusID: Status.ID, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = statusID
    }

    public var authorization: Authorization
    public let statusID: Status.ID
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/statuses/\(statusID)/unpin" }
}
