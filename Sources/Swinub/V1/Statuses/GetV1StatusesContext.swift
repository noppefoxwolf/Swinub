import Foundation
import HTTPTypes

public struct GetV1StatusesContext: AuthorizationRequest, Sendable {
    public typealias Response = StatusContext

    public init(id: Status.ID, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = id
    }
    public let authorization: Authorization
    public let statusID: Status.ID
    public var authority: String { authorization.host }
    public let method: RequestMethod = .http(.get)
    public var path: String { "/api/v1/statuses/\(statusID)/context" }
}

public struct StatusContext: Codable, Sendable {
    public let ancestors: [Status]
    public let descendants: [Status]
}
