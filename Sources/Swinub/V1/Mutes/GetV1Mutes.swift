import Foundation
import HTTPTypes

public struct GetV1Mutes: HTTPEndpointRequest, Sendable {
    public typealias Response = [Account]

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization
    public var limit: Int = 40
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/mutes" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            //                "max_id" : 0, //Internal parameter.
            //                "since_id" : 0, // Internal parameter.
            "limit": limit
        ]
    }
}
