import Foundation
import HTTPTypes

public struct GetV1StatusesStatus: AuthorizationRequest, Sendable {
    public typealias Response = Status

    public init(id: Status.ID, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = id
    }
    public let authorization: Authorization
    public let statusID: Status.ID
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/statuses/\(statusID)" }
}
