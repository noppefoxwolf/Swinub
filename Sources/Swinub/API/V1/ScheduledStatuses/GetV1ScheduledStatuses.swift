import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/scheduled_statuses/#get
public struct GetV1ScheduledStatuses: HTTPEndpointRequest, Sendable {
    public typealias Response = [ScheduledStatus]

    public init(
        authorization: Authorization,
        maxID: ScheduledStatus.ID? = nil,
        sinceID: ScheduledStatus.ID? = nil,
        minID: ScheduledStatus.ID? = nil,
        limit: Int? = nil
    ) {
        self.authorization = authorization
        self.maxID = maxID
        self.sinceID = sinceID
        self.minID = minID
        self.limit = limit
    }

    public let authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/scheduled_statuses" }
    public let method: HTTPRequest.Method = .get

    public let maxID: ScheduledStatus.ID?
    public let sinceID: ScheduledStatus.ID?
    public let minID: ScheduledStatus.ID?
    public let limit: Int?

    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let maxID {
            items.append(URLQueryItem(name: "max_id", value: maxID.rawValue))
        }
        if let sinceID {
            items.append(URLQueryItem(name: "since_id", value: sinceID.rawValue))
        }
        if let minID {
            items.append(URLQueryItem(name: "min_id", value: minID.rawValue))
        }
        if let limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        return items
    }
}
