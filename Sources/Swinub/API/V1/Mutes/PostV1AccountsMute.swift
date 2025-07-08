import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/accounts/#mute
public struct PostV1AccountsMute: HTTPEndpointRequest, Sendable {
    public typealias Response = Relationship

    public init(accountID: Account.ID, authorization: Authorization) {
        self.accountID = accountID
        self.authorization = authorization
    }
    public let accountID: Account.ID
    public let authorization: Authorization
    public var byAccountID: Account.ID { authorization.accountID }
    public var notifications: Bool = true
    public var duration: Int = 0
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/accounts/\(accountID)/mute" }
    public var body: EndpointRequestBody? {
        .json([
            "notifications": notifications,
            "duration": duration,
        ])
    }
}
