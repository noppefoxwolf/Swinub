import Foundation
import HTTPTypes

public struct PostV1AccountsUnsubscribe: HTTPEndpointRequest, Sendable {
    public typealias Response = Relationship

    public init(id: Account.ID, authorization: Authorization) {
        self.accountID = id
        self.authorization = authorization
    }

    public let accountID: Account.ID
    public var byAccountID: Account.ID { authorization.accountID }
    public var authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/accounts/\(accountID)/unsubscribe" }
    public let method: HTTPRequest.Method = .post

    public var listID: List.ID?

    public var body: EndpointRequestBody? {
        guard let listID else { return nil }
        return .json([
            "list_id": listID.rawValue
        ])
    }
}
