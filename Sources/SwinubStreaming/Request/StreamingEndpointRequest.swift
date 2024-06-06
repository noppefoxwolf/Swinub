import Swinub
import Foundation

public protocol StreamingEndpointRequest: EndpointRequest {
    func makeURLRequest() throws -> URLRequest
}

extension StreamingEndpointRequest {
    public var scheme: String { "wss" }
}
