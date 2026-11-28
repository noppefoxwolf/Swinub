import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/scheduled_statuses/#update
public struct PutV1ScheduledStatus: HTTPEndpointRequest, Sendable {
    public typealias Response = ScheduledStatus

    public init(
        id: ScheduledStatus.ID,
        scheduledAt: Date? = nil,
        authorization: Authorization
    ) {
        self.id = id
        self.scheduledAt = scheduledAt
        self.authorization = authorization
    }

    public let id: ScheduledStatus.ID
    public let scheduledAt: Date?
    public let authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/scheduled_statuses/\(id)" }
    public let method: HTTPRequest.Method = .put

    public var body: EndpointRequestBody? {
        var body: [String: Any] = [:]
        if let scheduledAt {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            body["scheduled_at"] = formatter.string(from: scheduledAt)
        }
        return .json(body)
    }
}
