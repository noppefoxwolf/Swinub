import Foundation
import HTTPTypes

public struct GetV1TagsByID: AuthorizationEndpointRequest, Sendable {
    public typealias Response = Tag

    public init(id: String, authorization: Authorization) {
        self.id = id
        self.authorization = authorization
    }
    let id: String
    public let authorization: Authorization
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String {
        let tag = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return "/api/v1/tags/\(tag)"
    }
}
