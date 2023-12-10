import Foundation
import HTTPTypes

public struct GetV1StatusesFavouritedBy: AuthorizationRequest {
    public typealias Response = [Account]

    public init(statusID: String, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = statusID
    }
    public var authorization: Authorization
    public let statusID: String
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/statuses/\(statusID)/favourited_by" }
}
