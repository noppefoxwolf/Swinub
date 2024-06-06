import Foundation
import HTTPTypes

public struct GetV1AccountsLookup: HTTPEndpointRequest, Sendable {
    public typealias Response = Account

    public init(host: String, acct: String) {
        self.host = host
        self.acct = acct
    }

    public var host: String
    public var acct: String
    public var path: String { "/api/v1/accounts/lookup" }
    public let method: HTTPRequest.Method = .get
    public var authority: String { host }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "acct": acct
        ]
    }
}
