import Foundation
import HTTPTypes

public struct DeleteV2Filter: AuthorizationRequest, Sendable {
    public typealias Response = DeleteV2FilterResponse

    public init(
        authorization: Authorization,
        filterID: String
    ) {
        self.authorization = authorization
        self.filterID = filterID
    }
    public let authorization: Authorization
    public var filterID: String
    
    public var authority: String { authorization.host }
    public var path: String { "/api/v2/filters/\(filterID)" }
    public let method: HTTPRequest.Method = .delete
}

public struct DeleteV2FilterResponse: Codable, Sendable {}
