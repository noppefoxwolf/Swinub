import Foundation
import HTTPTypes

public struct PutV1PushSubscription: HTTPEndpointRequest, Sendable {
    public typealias Response = WebPushSubscription

    public init(
        authorization: Authorization
    ) {
        self.authorization = authorization
    }
    public var authorization: Authorization
    public var configuration: SubscriptionConfiguration = .init()
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .put
    public var path: String { "/api/v1/push/subscription" }
    public var body: EndpointRequestBody? {
        .json([
            "data": [
                "policy": configuration.policy.rawValue,
                "alerts": configuration.alerts.parameters,
            ]
        ])
    }
}
