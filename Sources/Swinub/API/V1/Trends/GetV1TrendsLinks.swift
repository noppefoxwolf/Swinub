import Foundation
import HTTPTypes

public struct GetV1TrendsLinks: HTTPEndpointRequest, Sendable {
    public typealias Response = [TrendsLink]

    public init(host: String, limit: Int? = nil, offset: Int? = nil) {
        self.host = host
        self.limit = limit
        self.offset = offset
    }

    let host: String
    let limit: Int?
    let offset: Int?

    public var authority: String { host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/trends/links" }
    
    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        if let limit = limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        if let offset = offset {
            items.append(URLQueryItem(name: "offset", value: String(offset)))
        }
        
        return items
    }
}