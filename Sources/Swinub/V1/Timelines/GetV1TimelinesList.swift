import Foundation
import HTTPTypes

public struct GetV1TimelinesList: AuthorizationRequest {
    public typealias Response = [Status]

    public init(authorization: Authorization, listID: String) {
        self.authorization = authorization
        self.listID = listID
    }
    public let authorization: Authorization
    public var sinceID: String? = nil
    public var nextCursor: NextCursor? = nil
    public var prevCursor: PrevCursor? = nil
    public var limit: Int = 20
    let listID: String

    public var authority: String { authorization.host }
    public var path: String { "/api/v1/timelines/list/\(listID)" }
    public let method: HTTPRequest.Method = .get
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "since_id": sinceID,
            "max_id": nextCursor?.maxID,
            "min_id": prevCursor?.minID,
            "limit": limit,
        ]
    }
}
