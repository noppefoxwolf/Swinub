import Foundation
import HTTPTypes

public struct GetV1AccountsByID: AuthorizationRequest {
    public typealias Response = Account

    public init(id: String, authorization: Authorization) {
        self.accountID = id
        self.authorization = authorization
    }

    public var accountID: String
    public var authorization: Authorization
    public var path: String { "/api/v1/accounts/\(accountID)" }
    public let method: HTTPRequest.Method = .get
    public var authority: String { authorization.host }
}
