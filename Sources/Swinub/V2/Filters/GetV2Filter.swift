import Foundation
import HTTPTypes

public struct GetV2Filter: AuthorizationEndpointRequest, Sendable {
    public typealias Response = Filter

    public init(authorization: Authorization, filterID: String) {
        self.authorization = authorization
        self.filterID = filterID
    }
    public let authorization: Authorization
    let filterID: String
    
    public var authority: String { authorization.host }
    public var path: String { "/api/v2/filters/\(filterID)" }
    public let method: HTTPRequest.Method = .get
}
