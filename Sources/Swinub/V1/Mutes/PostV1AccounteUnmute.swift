import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/accounts/#mute
public struct PostV1AccountsUnmute: RelashionshipAuthorizationRequest {
    public typealias Response = Relationship

    public init(accountID: String, authorization: Authorization) {
        self.accountID = accountID
        self.authorization = authorization
    }
    public let accountID: String
    public let authorization: Authorization
    public var byAccountID: String { authorization.accountID }
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/accounts/\(accountID)/unmute" }
}
