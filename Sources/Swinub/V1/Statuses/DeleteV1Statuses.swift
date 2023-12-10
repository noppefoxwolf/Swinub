import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/statuses/#delete
public struct DeleteV1Statuses: AuthorizationRequest {
    public typealias Response = DeleteV1StatusesResponse

    public init(statusID: String, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = statusID
    }
    public var authorization: Authorization
    public let statusID: String
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .delete
    public var path: String { "/api/v1/statuses/\(statusID)" }
}

public struct DeleteV1StatusesResponse: Codable {}
