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
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/notifications/\(notificationID)" }
}
