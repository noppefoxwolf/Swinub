import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/notifications/#get
public struct GetV1NotificationsByID: HTTPEndpointRequest, Sendable {
    public typealias Response = Notification

    public init(notificationID: Notification.ID, authorization: Authorization) {
        self.notificationID = notificationID
        self.authorization = authorization
    }
    public let authorization: Authorization
    public var notificationID: Notification.ID
    /// Set to an empty array to request all available fallback representations.
    public var supportedTypes: [String]?
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/notifications/\(notificationID)" }
    public var queryItems: [URLQueryItem] {
        guard let supportedTypes else { return [] }
        // An empty array needs a value on the wire so Mastodon opts into fallback serialization.
        return (supportedTypes.isEmpty ? [""] : supportedTypes).map {
            URLQueryItem(name: "supported_types[]", value: $0)
        }
    }
}
