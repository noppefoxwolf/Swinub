import Swinub
import Foundation

public protocol StreamingEndpointRequest: EndpointRequest {
    func makeURLRequest() throws -> URLRequest
}

public protocol OptionalAuthorizationStreamingEndpointRequest: StreamingEndpointRequest {
    var authorization: Authorization? { get }
}

extension StreamingEndpointRequest {
    public var scheme: String { "wss" }
}
