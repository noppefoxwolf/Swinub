import Foundation
import HTTPTypes

public struct GetV1AccountStatuses: HTTPEndpointRequest, Sendable {
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
        if pinned {
            items.append(URLQueryItem(name: "pinned", value: "true"))
        }
        if onlyMedia {
            items.append(URLQueryItem(name: "only_media", value: "true"))
        }
        return items
    }
}
