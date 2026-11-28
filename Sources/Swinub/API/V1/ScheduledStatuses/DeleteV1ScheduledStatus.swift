import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/scheduled_statuses/#cancel
public struct DeleteV1ScheduledStatus: HTTPEndpointRequest, Sendable {
    public typealias Response = DeleteV1ScheduledStatusResponse

    public init(
        id: ScheduledStatus.ID,
        authorization: Authorization
    ) {
        self.id = id
        self.authorization = authorization
    }

    public let id: ScheduledStatus.ID
    public let authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/scheduled_statuses/\(id)" }
    public let method: HTTPRequest.Method = .delete
}

public struct DeleteV1ScheduledStatusResponse: Codable, Sendable {}
