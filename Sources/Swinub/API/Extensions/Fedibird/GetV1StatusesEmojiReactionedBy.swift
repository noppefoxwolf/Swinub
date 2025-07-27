import Foundation
import HTTPTypes

public struct GetV1StatusesEmojiReactionedBy: HTTPEndpointRequest, Sendable {
    public typealias Response = [Account]

    public init(
        statusID: Status.ID,
        authorization: Authorization,
        maxID: String? = nil,
        sinceID: String? = nil,
        limit: Int? = nil
    ) {
        self.statusID = statusID
        self.authorization = authorization
        self.maxID = maxID
        self.sinceID = sinceID
        self.limit = limit
    }

    public let statusID: Status.ID
    public var byAccountID: Account.ID { authorization.accountID }
    public let authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/statuses/\(statusID)/emoji_reactioned_by" }
    public let method: HTTPRequest.Method = .get

    public let maxID: String?
    public let sinceID: String?
    public let limit: Int?

    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let maxID = maxID {
            items.append(URLQueryItem(name: "max_id", value: maxID))
        }
        if let sinceID = sinceID {
            items.append(URLQueryItem(name: "since_id", value: sinceID))
        }
        if let limit = limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        return items
    }
}