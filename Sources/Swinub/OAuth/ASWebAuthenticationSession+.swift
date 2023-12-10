@preconcurrency import AuthenticationServices

extension ASWebAuthenticationSession {
    public static func authorize(
        host: String,
        clientId: String,
        redirectUri: String,
        scopes: [Scope],
        completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler
    ) -> ASWebAuthenticationSession {
        var urlComponents = URLComponents(string: "https://\(host)/oauth/authorize")!
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: scopes.map(\.rawValue).joined(separator: " ")),
            URLQueryItem(name: "lang", value: "ja-JP"),
        ]
        let redirectURI = URL(string: redirectUri)!
        let session = ASWebAuthenticationSession(
            url: urlComponents.url!,
            callbackURLScheme: redirectURI.scheme!,
            completionHandler: completionHandler
        )
        #if !DEBUG
        session.prefersEphemeralWebBrowserSession = true
        #endif
        return session
    }

    @MainActor
    public static func callbackURL(
        host: String,
        clientId: String,
        redirectUri: String,
        scopes: [Scope],
        presentationContextProvider: (any ASWebAuthenticationPresentationContextProviding)? = nil
    ) -> AsyncThrowingStream<URL, any Error> {
        AsyncThrowingStream<URL, any Error>(bufferingPolicy: .unbounded) { continuation in
            let session = ASWebAuthenticationSession.authorize(
                host: host,
                clientId: clientId,
                redirectUri: redirectUri,
                scopes: scopes,
                completionHandler: { (url, error) in
                    if let error = error {
                        continuation.finish(throwing: error)
                    }
                    if let url = url {
                        continuation.yield(url)
                        continuation.finish()
                    }
                }
            )
            continuation.onTermination = { @Sendable _ in
                session.cancel()
            }
            session.presentationContextProvider = presentationContextProvider
            session.start()
        }
    }
}
