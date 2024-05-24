import Foundation
import HTTPTypes

public struct GetV1Filters: AuthorizationRequest, Sendable {
    public typealias Response = [FilterV1]

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization
    public var authority: String { authorization.host }
    public let method: RequestMethod = .http(.get)
    public var path: String { "/api/v1/filters" }
}
