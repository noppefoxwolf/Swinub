import Foundation
import HTTPTypes

public struct GetV1TrendsStatuses: HTTPEndpointRequest, Sendable {
    public typealias Response = [Status]

    public init(host: String, limit: Int? = nil, offset: Int? = nil, lang: String? = nil) {
        self.host = host
        self.limit = limit
        self.offset = offset
        self.lang = lang
    }

    let host: String
    let limit: Int?
    let offset: Int?
    let lang: String?

    public var authority: String { host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/trends/statuses" }
    
    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        if let limit = limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        if let offset = offset {
            items.append(URLQueryItem(name: "offset", value: String(offset)))
        }
        
        if let lang = lang {
            items.append(URLQueryItem(name: "lang", value: lang))
        }
        
        return items
    }
}