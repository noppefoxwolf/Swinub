import Foundation
import HTTPTypes

public struct GetV1CustomEmojis: HTTPEndpointRequest, Sendable {
    public typealias Response = [CustomEmoji]
    public typealias AuthorizationType = Authorization?

    public init(host: String) {
        self.host = host
    }

    public var authorization: Authorization? = nil
    public let host: String
    public var authority: String { host }
    public var path: String { "/api/v1/custom_emojis" }
    public let method: HTTPRequest.Method = .get
}
