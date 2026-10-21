import Foundation
import HTTPTypes

public struct PostOAuthToken: HTTPEndpointRequest, Sendable {
    public typealias Response = OAuthToken

    public init(
        host: String,
        clientId: String,
        clientSecret: String,
        redirectUri: String,
        code: String,
        scopes: [Scope],
        codeVerifier: String? = nil
    ) {
        self.host = host
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
        self.code = code
        self.scopes = scopes
        self.codeVerifier = codeVerifier
    }

    var host: String
    var clientId: String
    var clientSecret: String
    var redirectUri: String
    var code: String
    var scopes: [Scope]
    var codeVerifier: String?

    public var authority: String { host }
    public var path: String { "/oauth/token" }
    public let method: HTTPRequest.Method = .post
    public var body: EndpointRequestBody? {
        var parameters = [
            "grant_type": "authorization_code",
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": redirectUri,
            "code": code,
            "scope": scopes.map(\.rawValue).joined(separator: " "),
        ]
        if let codeVerifier {
            parameters["code_verifier"] = codeVerifier
        }
        return .json(parameters)
    }

    public func decode(_ data: Data) throws -> OAuthToken {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(OAuthToken.self, from: data)
    }
}

public struct OAuthToken: Codable, Sendable {
    public let accessToken: String
    public let tokenType: String
    public let scope: String
    public let createdAt: Date
}
