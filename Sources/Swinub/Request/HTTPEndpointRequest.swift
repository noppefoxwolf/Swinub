import Foundation
import HTTPTypes

public protocol HTTPEndpointRequest: EndpointRequest {
    var method: HTTPRequest.Method { get }
    func makeHTTPRequest() throws -> (HTTPRequest, Data)
}
