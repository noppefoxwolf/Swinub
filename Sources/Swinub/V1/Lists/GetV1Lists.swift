import Foundation
import HTTPTypes

public struct GetV1Lists: AuthorizationRequest, Sendable {
    public typealias Response = [List]

    public init(authorization: Authorization) {
        self.authorization = authorization
    }

    public let authorization: Authorization
    public var authority: String { authorization.host }
    public let method: RequestMethod = .http(.get)
    public var path: String { "/api/v1/lists" }
}
