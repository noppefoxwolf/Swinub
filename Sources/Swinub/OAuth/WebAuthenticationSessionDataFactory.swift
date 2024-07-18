import Foundation

public struct WebAuthenticationSessionDataFactory {
    let host: String
    let clientId: String
    let redirectUri: String
    let scopes: [Scope]
    
    public init(host: String, clientId: String, redirectUri: String, scopes: [Scope]) {
        self.host = host
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.scopes = scopes
    }
    
    public func makeURL() throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = "/oauth/authorize"
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: scopes.map(\.rawValue).joined(separator: " ")),
            URLQueryItem(name: "lang", value: "ja-JP"),
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
