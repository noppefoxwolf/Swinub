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
    /// Set to an empty array to request all available fallback representations.
    public var supportedTypes: [String]?
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
        items += (types ?? []).map { URLQueryItem(name: "types[]", value: $0) }
        return items + fallbackQueryItems
    }
    private var fallbackQueryItems: [URLQueryItem] {
        guard let supportedTypes else { return [] }
        // An empty array needs a value on the wire so Mastodon opts into fallback serialization.
        return (supportedTypes.isEmpty ? [""] : supportedTypes).map {
            URLQueryItem(name: "supported_types[]", value: $0)
        }
    }
}
