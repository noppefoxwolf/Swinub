import HTTPTypes
import Foundation

public protocol EndpointRequest: Sendable {
    associatedtype Response: Decodable & Sendable
    associatedtype AuthorizationType: Sendable
    var scheme: String { get }
    var authority: String { get }
    var path: String { get }
    var url: URL { get throws }
    var authorization: AuthorizationType { get }
    
    var parameters: [String: (any RequestParameterValue)?] { get }
    
    func decode(_ data: Data) throws -> Response
}
