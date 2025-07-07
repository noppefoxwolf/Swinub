import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/search/#v2
public struct GetV2Search: HTTPEndpointRequest, Sendable {
    public typealias Response = Search

    public init(authorization: Authorization, q: String) {
        self.authorization = authorization
        self.q = q
    }
    public var authorization: Authorization
    let q: String
    public var sinceID: Status.ID? = nil
    public var nextCursor: NextCursor? = nil
    public var prevCursor: PrevCursor? = nil
    public var limit: Int = 20
    public var resolve: Bool = false
    
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v2/search" }
    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "type", value: "statuses"),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let sinceID = sinceID?.rawValue {
            items.append(URLQueryItem(name: "since_id", value: sinceID))
        }
        if let maxID = nextCursor?.maxID {
            items.append(URLQueryItem(name: "max_id", value: maxID))
        }
        if let minID = prevCursor?.minID {
            items.append(URLQueryItem(name: "min_id", value: minID))
        }
        if resolve {
            items.append(URLQueryItem(name: "resolve", value: "true"))
        }
        return items
    }
}
