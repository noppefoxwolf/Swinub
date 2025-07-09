import Foundation

public struct WebAuthenticationSessionDataFactory {
    let host: String
    let clientId: String
    let redirectUri: String
    let scopes: [Scope]

    public init(host: String, clientId: String, redirectUri: String, scopes: [Scope] = [.read]) {
        self.host = host
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.scopes = scopes
    }

    /// https://docs.joinmastodon.org/methods/oauth/#authorize
    public func makeURL(
        locale: Locale = .current
    ) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = "/oauth/authorize"
        urlComponents.queryItems = [

            // Should be set equal to code.
            URLQueryItem(name: "response_type", value: "code"),

            // The client ID, obtained during app registration.
            URLQueryItem(name: "client_id", value: clientId),

            // Set a URI to redirect the user to. If this parameter is set to urn:ietf:wg:oauth:2.0:oob then the authorization code will be shown instead. Must match one of the redirect_uris declared during app registration.
            URLQueryItem(name: "redirect_uri", value: redirectUri),

            // List of requested OAuth scopes, separated by spaces (or by pluses, if using query parameters). Must be a subset of scopes declared during app registration. If not provided, defaults to read.
            URLQueryItem(name: "scope", value: scopes.map(\.rawValue).joined(separator: " ")),

            // The ISO 639-1 two-letter language code to use while rendering the authorization form.
            URLQueryItem(
                name: "lang",
                value: locale.identifier
            ),
        ]
        let url = urlComponents.url
        guard let url else {
            throw GeneralError(errorDescription: "Can not make auth url.")
        }
        return url
    }

    public func makeCallbackURLScheme() throws -> String {
        let redirectURI = URL(string: redirectUri)
        guard let callbackURLScheme = redirectURI?.scheme else {
            throw GeneralError(errorDescription: "Can not make callback url.")
        }
        return callbackURLScheme
    }
}
