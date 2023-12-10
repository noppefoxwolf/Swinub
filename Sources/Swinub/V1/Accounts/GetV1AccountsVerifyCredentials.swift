import Foundation
import HTTPTypes

public struct GetV1AccountsVerifyCredentials: AuthorizationRequest {
    public typealias Response = Account

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/accounts/verify_credentials" }
    public let method: HTTPRequest.Method = .get
}
