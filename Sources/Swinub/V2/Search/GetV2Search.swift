import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/search/#v2
public struct GetV2Search: AuthorizationRequest, Sendable {
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
    public let method: RequestMethod = .http(.get)
    public var path: String { "/api/v2/search" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "q": q,
            "type": "statuses",
            "since_id": sinceID?.rawValue,
            "max_id": nextCursor?.maxID,
            "min_id": prevCursor?.minID,
            "limit": limit,
            "resolve": resolve,
        ]
    }
}
