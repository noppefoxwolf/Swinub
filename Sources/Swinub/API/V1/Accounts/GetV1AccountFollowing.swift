import Foundation
import HTTPTypes

public struct GetV1AccountFollowing: HTTPEndpointRequest, Sendable {
    public typealias Response = [Account]

    public init(accountID: Account.ID, authorization: Authorization) {
        self.accountID = accountID
        self.authorization = authorization
    }
    public let accountID: Account.ID
    public let authorization: Authorization
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/accounts/\(accountID)/following" }
    public var authority: String { authorization.host }
    public var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "limit", value: "40")
        ]
    }
}
