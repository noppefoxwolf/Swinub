import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/notifications/#get
public struct GetV1NotificationsByID: AuthorizationRequest {
    public typealias Response = Notification

    public init(notificationID: String, authorization: Authorization) {
        self.notificationID = notificationID
        self.authorization = authorization
    }
    public let authorization: Authorization
    public var notificationID: String
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/notifications/\(notificationID)" }
}
