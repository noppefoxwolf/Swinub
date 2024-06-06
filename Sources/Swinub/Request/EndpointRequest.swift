import HTTPTypes
import Foundation

public enum RequestMethod: Equatable, Sendable {
    case http(HTTPTypes.HTTPRequest.Method)
    case webSocket
    
    // convenience
    public static var get: RequestMethod { .http(.get) }
    public static var post: RequestMethod { .http(.post) }
    public static var put: RequestMethod { .http(.put) }
    public static var patch: RequestMethod { .http(.patch) }
    public static var delete: RequestMethod { .http(.delete) }
}

public protocol EndpointRequest: Sendable {
    associatedtype Response: Decodable & Sendable
    
    var method: RequestMethod { get }
    
    var scheme: String { get }
    var authority: String { get }
    var path: String { get }
    var url: URL { get throws }
    
    var parameters: [String: (any RequestParameterValue)?] { get }
    
    func makeURLRequest() throws -> URLRequest
    func decode(_ data: Data) throws -> Response
}

public protocol AuthorizationRequest: EndpointRequest {
    var authorization: Authorization { get }
}

public protocol OptionalAuthorizationRequest: EndpointRequest {
    var authorization: Authorization? { get }
}
