import Foundation
import HTTPTypes

public struct GetV1AccountsSubscribing: HTTPEndpointRequest, Sendable {
    public typealias Response = [Account]

    public init(authorization: Authorization) {
        self.authorization = authorization
    }

    public let authorization: Authorization
    public let method: HTTPRequest.Method = .get
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/accounts/subscribing" }

    public var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "limit", value: "40")
        ]
    }
}
