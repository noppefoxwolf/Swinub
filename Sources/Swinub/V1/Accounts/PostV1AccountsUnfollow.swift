import Foundation
import HTTPTypes

public struct PostV1AccountsUnfollow: AuthorizationRequest, Sendable {
    public typealias Response = Relationship

    public init(id: Account.ID, authorization: Authorization) {
        self.accountID = id
        self.authorization = authorization
    }

    public let accountID: Account.ID
    public var byAccountID: Account.ID { authorization.accountID }
    public var authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/accounts/\(accountID)/unfollow" }
    public let method: RequestMethod = .post
}
