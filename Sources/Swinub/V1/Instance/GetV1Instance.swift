import Foundation
import HTTPTypes

// https://fedibird.com/api/v1/instance
// https://docs.joinmastodon.org/methods/instance/#v1
public struct GetV1Instance: Request {
    public typealias Response = InstanceV1

    public init(host: String) {
        self.host = host
    }

    public let host: String
    public var authority: String { host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/instance" }
}
