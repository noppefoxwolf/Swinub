import Foundation
import HTTPTypes

public struct GetV1ListAccounts: HTTPEndpointRequest, Sendable {
    public typealias Response = [Account]

    public init(authorization: Authorization, listID: String) {
        self.authorization = authorization
        self.listID = listID
    }

    public let authorization: Authorization
    public let listID: String
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/lists/\(listID)/accounts" }
}
