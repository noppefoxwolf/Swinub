import Foundation
import HTTPTypes

public struct GetV2Suggestions: HTTPEndpointRequest, Sendable {
    public typealias Response = [Suggestion]

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public var authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v2/suggestions" }
    public let method: HTTPRequest.Method = .get
}
