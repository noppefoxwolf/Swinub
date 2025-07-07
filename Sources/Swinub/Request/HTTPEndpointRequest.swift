import Foundation
import HTTPTypes

public protocol HTTPEndpointRequest: EndpointRequest {
    var method: HTTPRequest.Method { get }
    func makeHTTPRequest() async throws -> (HTTPRequest, Data)
}
