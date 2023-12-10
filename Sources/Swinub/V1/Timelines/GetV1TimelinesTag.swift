import Foundation
import HTTPTypes

public struct GetV1TimelinesTag: TimelineAuthorizationRequest {
    public typealias Response = [Status]

    public init(authorization: Authorization, hashtag: String) {
        self.authorization = authorization
        self.hashtag = hashtag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    }
    public let authorization: Authorization
    public var sinceID: String? = nil
    public var nextCursor: NextCursor? = nil
    public var prevCursor: PrevCursor? = nil
    public var limit: Int = 20
    let hashtag: String
    public let method: HTTPRequest.Method = .get

    public var authority: String { authorization.host }
    public var path: String { "/api/v1/timelines/tag/\(hashtag)" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "since_id": sinceID,
            "max_id": nextCursor?.maxID,
            "min_id": prevCursor?.minID,
            "limit": limit,
        ]
    }
}
