import Foundation
import HTTPTypes

public struct GetV1AccountFollowers: AuthorizationRequest {
    public typealias Response = [Account]

    public init(accountID: String, authorization: Authorization) {
        self.accountID = accountID
        self.authorization = authorization
    }
    public let accountID: String
    public let authorization: Authorization
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/accounts/\(accountID)/followers" }
    public var authority: String { authorization.host }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "limit": 40
        ]
    }
}
