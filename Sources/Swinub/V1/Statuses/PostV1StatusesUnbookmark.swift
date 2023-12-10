import Foundation
import HTTPTypes

public struct PostV1StatusesUnbookmark: AuthorizationRequest {
    public typealias Response = Status

    public init(id: String, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = id
    }
    public let authorization: Authorization
    public let statusID: String
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/statuses/\(statusID)/unbookmark" }
}
