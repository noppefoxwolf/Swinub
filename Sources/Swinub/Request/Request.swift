import os
import HTTPTypes
import Foundation

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public protocol Request: Sendable {
    associatedtype Response: Codable
    var method: HTTPRequest.Method { get }
    
    var scheme: String { get }
    var authority: String { get }
    var path: String { get }
    var url: URL { get }
    
    var parameters: [String: (any RequestParameterValue)?] { get }
    
    var decoder: JSONDecoder { get }
    func makeURLRequest() throws -> URLRequest
}

public protocol AuthorizationRequest: Request {
    var authorization: Authorization { get }
}

