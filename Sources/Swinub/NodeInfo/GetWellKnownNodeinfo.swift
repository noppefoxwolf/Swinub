import Foundation
import HTTPTypes

public struct GetWellKnownNodeinfoResponse: Codable, Sendable {
    public let links: [NodeinfoLink]
}

public struct GetWellKnownNodeinfo: HTTPEndpointRequest, Sendable {
    public typealias Response = GetWellKnownNodeinfoResponse
    public typealias AuthorizationType = Never

    public init(host: String) {
        authority = host
    }

    public var path: String { "/.well-known/nodeinfo" }
    public let method: HTTPRequest.Method = .get
    public let authority: String
}
