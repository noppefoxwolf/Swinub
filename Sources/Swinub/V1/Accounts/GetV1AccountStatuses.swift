import Foundation
import HTTPTypes

public struct GetV1AccountStatuses: AuthorizationRequest, Sendable {
    public typealias Response = [Status]

    public init(accountID: Account.ID, authorization: Authorization) {
        self.accountID = accountID
        self.authorization = authorization
    }
    public let accountID: Account.ID
    public let authorization: Authorization
    public var sinceID: Status.ID? = nil
    public var nextCursor: NextCursor? = nil
    public var prevCursor: PrevCursor? = nil
    public var limit: Int = 20
    public var pinned: Bool = false
    public var onlyMedia: Bool = false
    
    public var path: String { "/api/v1/accounts/\(accountID)/statuses" }
    public let method: HTTPRequest.Method = .get
    public var authority: String { authorization.host }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "since_id": sinceID?.rawValue,
            "max_id": nextCursor?.maxID,
            "min_id": prevCursor?.minID,
            "limit": limit,
            "pinned": pinned,
            "only_media": onlyMedia,
        ]
    }
}
