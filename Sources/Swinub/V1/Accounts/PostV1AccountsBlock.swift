import Foundation
import HTTPTypes

public struct PostV1AccountsBlock: RelashionshipAuthorizationRequest {
    public typealias Response = Relationship

    public init(id: String, authorization: Authorization) {
        self.accountID = id
        self.authorization = authorization
    }

    public let accountID: String
    public var byAccountID: String { authorization.accountID }
    public var authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/accounts/\(accountID)/block" }
    public let method: HTTPRequest.Method = .post
}
