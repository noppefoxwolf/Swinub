import Foundation
import HTTPTypes

// https://fedibird.com/api/v1/instance
// https://docs.joinmastodon.org/methods/instance/#v1
public struct GetV1Instance: HTTPEndpointRequest, Sendable {
    public typealias Response = InstanceV1
    public typealias AuthorizationType = Never

    public init(host: String) {
        self.host = host
    }

    public var authorization: Authorization?
    public let host: String
    public var authority: String { host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/instance" }
}
