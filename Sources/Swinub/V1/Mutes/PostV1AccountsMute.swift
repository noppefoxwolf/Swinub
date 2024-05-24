import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/accounts/#mute
public struct PostV1AccountsMute: AuthorizationRequest, Sendable {
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
    public let method: RequestMethod = .http(.post)
    public var path: String { "/api/v1/accounts/\(accountID)/mute" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "notifications": notifications,
            "duration": duration,
        ]
    }
}
