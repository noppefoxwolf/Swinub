import Foundation
import HTTPTypes

public struct DeleteV1Filter: HTTPEndpointRequest, Sendable {
    public typealias Response = DeleteV1FilterResponse

    public init(
        authorization: Authorization,
        filterID: String
    ) {
        self.authorization = authorization
        self.filterID = filterID
    }
    public let authorization: Authorization
    public let filterID: String
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/filters/\(filterID)" }
    public let method: HTTPRequest.Method = .delete
}

public struct DeleteV1FilterResponse: Codable, Sendable {}
