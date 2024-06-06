import Foundation
import HTTPTypes

public struct GetV1AccountsByID: HTTPEndpointRequest, Sendable {
    public typealias Response = Account

    public init(id: Account.ID, authorization: Authorization) {
        self.accountID = id
        self.authorization = authorization
    }

    public var accountID: Account.ID
    public var authorization: Authorization
    public var path: String { "/api/v1/accounts/\(accountID)" }
    public let method: HTTPRequest.Method = .get
    public var authority: String { authorization.host }
}
