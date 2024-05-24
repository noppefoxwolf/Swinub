import Foundation
import HTTPTypes

public struct PostOAuthRevoke: Request, Sendable {
    public typealias Response = PostOAuthRevokeResponse

    public init(host: String, clientID: String, clientSecret: String, token: String) {
        self.host = host
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.token = token
    }

    var host: String
    var clientID: String
    var clientSecret: String
    var token: String
    
    public var authority: String { host }
    public var path: String { "/oauth/revoke" }
    public let method: RequestMethod = .post
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "client_id": clientID,
            "client_secret": clientSecret,
            "token": token,
        ]
    }
}

public struct PostOAuthRevokeResponse: Codable, Sendable {}
