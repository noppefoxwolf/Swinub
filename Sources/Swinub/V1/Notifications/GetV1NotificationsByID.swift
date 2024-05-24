import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/notifications/#get
public struct GetV1NotificationsByID: AuthorizationRequest, Sendable {
    public typealias Response = Notification

    public init(notificationID: Notification.ID, authorization: Authorization) {
        self.notificationID = notificationID
        self.authorization = authorization
    }
    public let authorization: Authorization
    public var notificationID: Notification.ID
    public var authority: String { authorization.host }
    public let method: RequestMethod = .http(.get)
    public var path: String { "/api/v1/notifications/\(notificationID)" }
}
