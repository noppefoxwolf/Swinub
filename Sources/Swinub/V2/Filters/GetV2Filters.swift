import Foundation
import HTTPTypes

public struct GetV2Filters: AuthorizationRequest, Sendable {
    public typealias Response = [Filter]

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization
    
    public var authority: String { authorization.host }
    public var path: String { "/api/v2/filters" }
    public let method: RequestMethod = .http(.get)
}
