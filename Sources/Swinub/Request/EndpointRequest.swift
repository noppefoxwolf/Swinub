import HTTPTypes
import Foundation

public protocol EndpointRequest: Sendable {
    associatedtype Response: Decodable & Sendable
    var scheme: String { get }
    var authority: String { get }
    var path: String { get }
    var url: URL { get throws }
    
    var parameters: [String: (any RequestParameterValue)?] { get }
    
    func decode(_ data: Data) throws -> Response
}

public protocol HTTPEndpointRequest: EndpointRequest {
    var method: HTTPRequest.Method { get }
    func makeHTTPRequest() throws -> (HTTPRequest, Data)
}

public protocol AuthorizationEndpointRequest: HTTPEndpointRequest {
    var authorization: Authorization { get }
}

public protocol OptionalAuthorizationHTTPEndpointRequest: HTTPEndpointRequest {
    var authorization: Authorization? { get }
}
