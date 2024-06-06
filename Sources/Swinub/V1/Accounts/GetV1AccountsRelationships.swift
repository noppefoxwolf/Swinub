import Foundation
import HTTPTypes

public struct GetV1AccountsRelationships: HTTPEndpointRequest, Sendable {
    public typealias Response = [Relationship]

    public init(ids: [Account.ID], authorization: Authorization) {
        self.accountIDs = ids
        self.authorization = authorization
    }

    public var accountIDs: [Account.ID]
    public var byAccountID: Account.ID { authorization.accountID }
    public let authorization: Authorization
    public var path: String { "/api/v1/accounts/relationships" }
    public let method: HTTPRequest.Method = .get
    public var authority: String { authorization.host }
    public var parameters: [String : (any RequestParameterValue)?] {
        ["id": accountIDs.map(\.rawValue).joined(separator: ",")]
    }
}
