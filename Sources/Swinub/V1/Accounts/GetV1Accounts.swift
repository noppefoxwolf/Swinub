import Foundation
import HTTPTypes

public struct GetV1Accounts: HTTPEndpointRequest, Sendable {
    public typealias Response = [Account]

    public init(ids: [Account.ID], authorization: Authorization) {
        self.ids = ids
        self.authorization = authorization
    }

    public var ids: [Account.ID]
    public var authorization: Authorization
    public var path: String { "/api/v1/accounts" }
    public let method: HTTPRequest.Method = .get
    public var authority: String { authorization.host }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "id[]" : ids.map(\.rawValue).joined(separator: ",")
        ]
    }
}
