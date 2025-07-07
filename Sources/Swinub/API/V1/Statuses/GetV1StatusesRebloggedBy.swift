import Foundation
import HTTPTypes

public struct GetV1StatusesRebloggedBy: HTTPEndpointRequest, Sendable {
    public typealias Response = [Account]

    public init(statusID: Status.ID, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = statusID
    }
    public var authorization: Authorization
    public let statusID: Status.ID
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/statuses/\(statusID)/reblogged_by" }
}
