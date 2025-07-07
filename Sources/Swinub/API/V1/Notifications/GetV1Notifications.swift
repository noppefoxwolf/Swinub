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
    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let minID = minID?.rawValue {
            items.append(URLQueryItem(name: "min_id", value: minID))
        }
        if let maxID = maxID?.rawValue {
            items.append(URLQueryItem(name: "max_id", value: maxID))
        }
        if let types = types {
            items.append(URLQueryItem(name: "types[]", value: types.joined(separator: ",")))
        }
        return items
    }
}
