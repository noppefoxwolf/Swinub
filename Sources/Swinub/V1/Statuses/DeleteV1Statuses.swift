import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/statuses/#delete
public struct DeleteV1Statuses: AuthorizationEndpointRequest, Sendable {
    public typealias Response = DeleteV1StatusesResponse

    public init(statusID: Status.ID, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = statusID
    }
    public var authorization: Authorization
    public let statusID: Status.ID
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .delete
    public var path: String { "/api/v1/statuses/\(statusID)" }
}

public struct DeleteV1StatusesResponse: Codable, Sendable {}
