import Foundation
import HTTPTypes

public struct GetV1PushSubscription: AuthorizationEndpointRequest, Sendable {
    public typealias Response = WebPushSubscription

    public init(
        authorization: Authorization
    ) {
        self.authorization = authorization
    }
    public var authorization: Authorization
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/push/subscription" }
}
