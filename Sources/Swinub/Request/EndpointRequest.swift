import HTTPTypes
import Foundation

public protocol EndpointRequest: Sendable {
    associatedtype Response: Decodable & Sendable
    associatedtype AuthorizationType: Sendable
    
    /// https
    var scheme: String { get }
    
    /// example.com
    var authority: String { get }
    
    /// /users/1
    var path: String { get }
    
    /// https://example.com/users/1
    var url: URL { get throws }
    
    var authorization: AuthorizationType { get }
    
    var queryItems: [URLQueryItem] { get }
    
    var parameters: [String: (any RequestParameterValue)?] { get }
    
    func decode(_ data: Data) throws -> Response
}
