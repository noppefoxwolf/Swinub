import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/notifications/#get
public struct GetV1Notifications: AuthorizationRequest {
    public typealias Response = [Notification]

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization
    public var minID: String? = nil
    public var maxID: String? = nil
    public var limit: Int = 30
    public var types: [String]?
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/notifications" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "min_id": minID,
            "max_id": maxID,
            "limit": limit,
            "types[]": types?.joined(separator: ","),
        ]
    }
}
