import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/notifications/#get
public struct GetV1Notifications: HTTPEndpointRequest, Sendable {
    public typealias Response = [Notification]

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization
    public var minID: Notification.ID? = nil
    public var maxID: Notification.ID? = nil
    public var limit: Int = 30
    public var types: [String]?
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/notifications" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "min_id": minID?.rawValue,
            "max_id": maxID?.rawValue,
            "limit": limit,
            "types[]": types?.joined(separator: ","),
        ]
    }
}
