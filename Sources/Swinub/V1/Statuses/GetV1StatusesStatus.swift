import Foundation
import HTTPTypes

public struct GetV1StatusesStatus: AuthorizationRequest {
    public typealias Response = Status

    public init(id: String, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = id
    }
    public let authorization: Authorization
    public let statusID: String
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/statuses/\(statusID)" }
}
