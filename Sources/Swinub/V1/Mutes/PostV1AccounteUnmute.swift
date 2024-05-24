import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/accounts/#mute
public struct PostV1AccountsUnmute: AuthorizationRequest, Sendable {
    public typealias Response = Relationship

    public init(accountID: Account.ID, authorization: Authorization) {
        self.accountID = accountID
        self.authorization = authorization
    }
    public let accountID: Account.ID
    public let authorization: Authorization
    public var byAccountID: Account.ID { authorization.accountID }
    public var authority: String { authorization.host }
    public let method: RequestMethod = .post
    public var path: String { "/api/v1/accounts/\(accountID)/unmute" }
}
