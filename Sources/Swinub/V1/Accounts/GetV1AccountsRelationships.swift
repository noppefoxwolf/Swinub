import Foundation
import HTTPTypes

public struct GetV1AccountsRelationships: RelashionshipsRequest, AuthorizationRequest {
    public typealias Response = [Relationship]

    public init(ids: [String], authorization: Authorization) {
        self.accountIDs = ids
        self.authorization = authorization
    }

    public var accountIDs: [String]
    public var byAccountID: String { authorization.accountID }
    public let authorization: Authorization
    public var path: String { "/api/v1/accounts/relationships" }
    public let method: HTTPRequest.Method = .get
    public var authority: String { authorization.host }
    public var parameters: [String : (any RequestParameterValue)?] {
        ["id": accountIDs.joined(separator: ",")]
    }
}
