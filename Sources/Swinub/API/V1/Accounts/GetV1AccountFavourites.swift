import Foundation
import HTTPTypes

public struct GetV1AccountFavourites: HTTPEndpointRequest, Sendable {
    public typealias Response = [Status]

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization
    public var sinceID: Status.ID? = nil
    public var nextCursor: NextCursor? = nil
    public var prevCursor: PrevCursor? = nil
    public var limit: Int = 20

    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/favourites" }
    public var authority: String { authorization.host }
    public var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "since_id", value: sinceID?.rawValue),
            URLQueryItem(name: "max_id", value: nextCursor?.maxID),
            URLQueryItem(name: "min_id", value: prevCursor?.minID),
            URLQueryItem(name: "limit", value: "\(limit)"),
        ]
    }
}
