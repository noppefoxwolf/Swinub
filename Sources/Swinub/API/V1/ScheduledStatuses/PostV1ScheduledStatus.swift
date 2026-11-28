import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/statuses/#create
public struct PostV1ScheduledStatus: HTTPEndpointRequest, Sendable {
    public typealias Response = ScheduledStatus

    public init(
        parameters: PostV1Statuses.Parameters,
        scheduledAt: Date,
        authorization: Authorization
    ) {
        self.parameters = parameters
        self.scheduledAt = scheduledAt
        self.authorization = authorization
    }

    public let parameters: PostV1Statuses.Parameters
    public let scheduledAt: Date
    public let authorization: Authorization
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/statuses" }

    public var body: EndpointRequestBody? {
        var body = parameters.makeJSONBody()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        body["scheduled_at"] = formatter.string(from: scheduledAt)
        return .json(body as Any)
    }
}
