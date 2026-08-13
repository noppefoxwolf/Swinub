import Foundation
import HTTPTypes

public struct GetV1StatusesStatus: HTTPEndpointRequest, Sendable {
    public typealias Response = Status
    public typealias AuthorizationType = Authorization?

    public init(id: Status.ID, host: String) {
        self.host = host
        self.statusID = id
    }

    public var authorization: Authorization?
    public let host: String
    public let statusID: Status.ID
    public var authority: String { host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/statuses/\(statusID)" }
}
