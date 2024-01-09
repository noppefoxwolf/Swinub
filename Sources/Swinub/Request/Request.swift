import os
import HTTPTypes
import Foundation

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public protocol Request: Sendable {
    associatedtype Response: Codable & Sendable
    var method: HTTPRequest.Method { get }
    
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

