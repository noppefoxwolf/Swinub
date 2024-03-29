import Foundation
import HTTPTypes

public struct GetV2Instance: OptionalAuthorizationRequest, Sendable {
    public typealias Response = Instance

    public init(host: String) {
        self.host = host
    }

    let host: String
    public var authorization: Authorization?
    public var authority: String { host }
    public var path: String { "/api/v2/instance" }
    public let method: HTTPRequest.Method = .get
}
