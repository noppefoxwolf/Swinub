import HTTPTypes
import Foundation

public enum RequestMethod: Equatable, Sendable {
    case http(HTTPTypes.HTTPRequest.Method)
    case webSocket
}

public protocol Request: Sendable {
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

public protocol AuthorizationRequest: Request {
    var authorization: Authorization { get }
}

public protocol OptionalAuthorizationRequest: Request {
    var authorization: Authorization? { get }
}
