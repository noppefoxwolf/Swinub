import Foundation
import Swinub

public struct OAuthOutOfBandAuthenticationService: Sendable {
    public static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"

    private let session: any Session

    public init(session: any Session = URLSession.shared) {
        self.session = session
    }

    public func makeAuthorizationRequest(
        host: String,
        clientName: String,
        scopes: [Scope] = [.read],
        locale: Locale = .current
    ) async throws -> OAuthOutOfBandAuthorizationRequest {
        let application = try await session.response(
            for: PostV1Apps(
                host: host,
                clientName: clientName,
                redirectURI: Self.redirectURI,
                scopes: scopes
            )
        ).response

        let pkce = OAuthPKCE()
        let authorizationURL = try WebAuthenticationSessionDataFactory(
            host: host,
            clientId: application.clientId,
            redirectUri: Self.redirectURI,
            scopes: scopes,
            pkce: pkce
        ).makeURL(locale: locale)

        return OAuthOutOfBandAuthorizationRequest(
            host: host,
            application: application,
            authorizationURL: authorizationURL,
            scopes: scopes,
            pkce: pkce
        )
    }

    public func exchangeCode(
        _ code: String,
        for request: OAuthOutOfBandAuthorizationRequest
    ) async throws -> OAuthToken {
        try await session.response(
            for: PostOAuthToken(
                host: request.host,
                clientId: request.application.clientId,
                clientSecret: request.application.clientSecret,
                redirectUri: Self.redirectURI,
                code: code,
                scopes: request.scopes,
                codeVerifier: request.pkce.codeVerifier
            )
        ).response
    }
}

public struct OAuthOutOfBandAuthorizationRequest: Sendable {
    public let host: String
    public let application: Application
    public let authorizationURL: URL
    public let scopes: [Scope]
    fileprivate let pkce: OAuthPKCE
}
