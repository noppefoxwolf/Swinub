import Foundation
import HTTPTypes

public struct GetV1TimelinesHome: HTTPEndpointRequest, Sendable {
    public typealias Response = [Status]

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization
    public var sinceID: Status.ID? = nil
    public var nextCursor: NextCursor? = nil
    public var prevCursor: PrevCursor? = nil
    public var limit: Int = 20

    public var authority: String { authorization.host }
    public let path = "/api/v1/timelines/home"
    public let method: HTTPRequest.Method = .get
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "since_id": sinceID?.rawValue,
            "max_id": nextCursor?.maxID,
            "min_id": prevCursor?.minID,
            "limit": limit,
        ]
    }
}
