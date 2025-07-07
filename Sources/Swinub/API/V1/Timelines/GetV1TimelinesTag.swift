import Foundation
import HTTPTypes

public struct GetV1TimelinesTag: HTTPEndpointRequest, Sendable {
    public typealias Response = [Status]

    public init(authorization: Authorization, hashtag: String) {
        self.authorization = authorization
        self.hashtag = hashtag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    }
    public let authorization: Authorization
    public var sinceID: Status.ID? = nil
    public var nextCursor: NextCursor? = nil
    public var prevCursor: PrevCursor? = nil
    public var limit: Int = 20
    let hashtag: String
    public let method: HTTPRequest.Method = .get

    public var authority: String { authorization.host }
    public var path: String { "/api/v1/timelines/tag/\(hashtag)" }
    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let sinceID = sinceID?.rawValue {
            items.append(URLQueryItem(name: "since_id", value: sinceID))
        }
        if let maxID = nextCursor?.maxID {
            items.append(URLQueryItem(name: "max_id", value: maxID))
        }
        if let minID = prevCursor?.minID {
            items.append(URLQueryItem(name: "min_id", value: minID))
        }
        items.append(URLQueryItem(name: "limit", value: String(limit)))
        return items
    }
}
