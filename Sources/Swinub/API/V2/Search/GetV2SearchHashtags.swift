import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/search/#v2
public struct GetV2SearchHashtags: HTTPEndpointRequest, Sendable {
    public typealias Response = Search

    public init(authorization: Authorization, q: String) {
        self.authorization = authorization
        self.q = q
    }

    public var authorization: Authorization
    let q: String
    public var limit: Int = 20
    public var offset: Int? = nil
    public var excludeUnreviewed: Bool = false
    public var nextCursor: NextCursor? = nil
    public var prevCursor: PrevCursor? = nil

    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v2/search" }
    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "type", value: "hashtags"),
            URLQueryItem(name: "limit", value: String(limit)),
        ]

        if let offset = offset {
            items.append(URLQueryItem(name: "offset", value: String(offset)))
        }

        if excludeUnreviewed {
            items.append(URLQueryItem(name: "exclude_unreviewed", value: "true"))
        }

        if let maxID = nextCursor?.maxID {
            items.append(URLQueryItem(name: "max_id", value: maxID))
        }
        if let minID = prevCursor?.minID {
            items.append(URLQueryItem(name: "min_id", value: minID))
        }

        return items
    }
}
