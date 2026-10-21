import CryptoKit
import Foundation

/// A per-authorization PKCE verifier and its S256 challenge.
/// Keep the verifier until token exchange; never include it in the authorization URL.
public struct OAuthPKCE: Sendable {
    public let codeVerifier: String

    public var codeChallenge: String {
        Data(SHA256.hash(data: Data(codeVerifier.utf8))).base64URLEncodedString
    }

    /// Creates a verifier with 256 bits of entropy from the system random generator.
    public init() {
        var generator = SystemRandomNumberGenerator()
        let bytes = (0..<32).map { _ in UInt8.random(in: .min ... .max, using: &generator) }
        codeVerifier = Data(bytes).base64URLEncodedString
    }

    /// Restores an RFC 7636 verifier (43–128 ASCII unreserved characters).
    public init(codeVerifier: String) throws {
        let allowed = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~".utf8)
        guard (43...128).contains(codeVerifier.utf8.count),
            codeVerifier.utf8.allSatisfy({ allowed.contains($0) })
        else {
            throw ValidationError.invalidCodeVerifier
        }
        self.codeVerifier = codeVerifier
    }

    public enum ValidationError: Error {
        case invalidCodeVerifier
    }
}

private extension Data {
    var base64URLEncodedString: String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
