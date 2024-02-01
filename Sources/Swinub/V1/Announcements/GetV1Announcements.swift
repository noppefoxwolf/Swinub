import Foundation
import HTTPTypes

public struct GetV1Announcements: AuthorizationRequest, Sendable {
    public typealias Response = [Announcement]

    public init(authorization: Authorization) {
        self.authorization = authorization
        self.host = authorization.host
    }
    public let authorization: Authorization
    public let host: String
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/announcements" }
    public let method: HTTPRequest.Method = .get
}
