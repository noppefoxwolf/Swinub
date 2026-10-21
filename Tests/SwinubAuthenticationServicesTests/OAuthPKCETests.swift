import HTTPTypes
import Foundation
import Swinub
import Testing
@testable import SwinubAuthenticationServices

struct OAuthPKCETests {
    @Test func rfc7636Challenge() throws {
        let pkce = try OAuthPKCE(codeVerifier: "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")
        #expect(pkce.codeChallenge == "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM")
        let url = try WebAuthenticationSessionDataFactory(
            host: "example.com", clientId: "client", redirectUri: "app://callback", pkce: pkce
        ).makeURL()
        let items = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)
        #expect(items.first { $0.name == "code_challenge" }?.value == pkce.codeChallenge)
        #expect(items.first { $0.name == "code_challenge_method" }?.value == "S256")
        #expect(!items.contains { $0.name == "code_verifier" })
    }

    @Test func outOfBandExchange() async throws {
        let session = RecordingSession()
        let service = OAuthOutOfBandAuthenticationService(session: session)
        let request = try await service.makeAuthorizationRequest(host: "example.com", clientName: "Test")
        _ = try await service.exchangeCode("authorization-code", for: request)
        let verifier = try #require(await session.verifier)
        let pkce = try OAuthPKCE(codeVerifier: verifier)
        let items = try #require(URLComponents(url: request.authorizationURL, resolvingAgainstBaseURL: false)?.queryItems)
        #expect(items.first { $0.name == "code_challenge" }?.value == pkce.codeChallenge)
    }

    @Test func legacyAuthorizationURL() throws {
        let url = try WebAuthenticationSessionDataFactory(host: "example.com", clientId: "client", redirectUri: "app://callback").makeURL()
        let items = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)
        #expect(!items.contains { $0.name.hasPrefix("code_challenge") })
    }

    @Test func generatedVerifiers() throws {
        let first = OAuthPKCE()
        let second = OAuthPKCE()
        #expect(first.codeVerifier.count == 43)
        #expect(first.codeVerifier != second.codeVerifier)
        #expect(try OAuthPKCE(codeVerifier: first.codeVerifier).codeChallenge == first.codeChallenge)
    }

    @Test(arguments: ["", String(repeating: "a", count: 42), String(repeating: "a", count: 129), String(repeating: "+", count: 43)])
    func invalidVerifier(value: String) {
        #expect(throws: OAuthPKCE.ValidationError.self) { try OAuthPKCE(codeVerifier: value) }
    }

    @Test(arguments: [false, true])
    func tokenBody(usesPKCE: Bool) throws {
        let verifier = usesPKCE ? OAuthPKCE().codeVerifier : nil
        let request = PostOAuthToken(host: "example.com", clientId: "client", clientSecret: "secret", redirectUri: "app://callback", code: "code", scopes: [.read], codeVerifier: verifier)
        guard case .json(let value) = request.body else {
            Issue.record("Expected JSON body")
            return
        }
        let body = try #require(value as? [String: String])
        #expect(body["code_verifier"] == verifier)
        #expect(body["client_secret"] == "secret")
    }
}

private actor RecordingSession: Session {
    var verifier: String?

    func response<T: HTTPEndpointRequest>(for request: T) async throws -> (response: T.Response, httpResponse: HTTPResponse) {
        let json: String
        if request.path == "/api/v1/apps" {
            json = #"{"id":"1","name":"Test","redirect_uri":"urn:ietf:wg:oauth:2.0:oob","client_id":"client","client_secret":"secret"}"#
        } else {
            if case .json(let value) = request.body {
                verifier = (value as? [String: String])?["code_verifier"]
            }
            json = #"{"access_token":"token","token_type":"Bearer","scope":"read","created_at":0}"#
        }
        return (try request.decode(Data(json.utf8)), HTTPResponse(status: .ok))
    }
}
