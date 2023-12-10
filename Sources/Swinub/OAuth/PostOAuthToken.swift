import Foundation
import HTTPTypes

public struct PostOAuthToken: Request {
    public typealias Response = OAuthToken

    public init(
        host: String,
        clientId: String,
        clientSecret: String,
        redirectUri: String,
        code: String,
        scopes: [Scope]
    ) {
        self.host = host
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        self.code = code
        self.scopes = scopes
    }

    var host: String
    var clientId: String
    var clientSecret: String
    var redirectUri: String
    var code: String
    var scopes: [Scope]
    
    public var authority: String { host }
    public var path: String { "/oauth/token" }
    public let method: HTTPRequest.Method = .post
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "grant_type": "authorization_code",
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": redirectUri,
            "code": code,
            "scope": scopes.map(\.rawValue).joined(separator: " "),
        ]
    }
    
    public func decode(_ data: Data) throws -> OAuthToken {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(OAuthToken.self, from: data)
    }
}

public struct OAuthToken: Codable {
    public let accessToken: String
    public let tokenType: String
    public let scope: String
    public let createdAt: Date
}
