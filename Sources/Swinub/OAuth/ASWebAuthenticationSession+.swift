@preconcurrency import AuthenticationServices

extension ASWebAuthenticationSession {
    @MainActor
    public static func authenticate(
        url: URL,
        callbackURLScheme: String,
        presentationContextProvider: (any ASWebAuthenticationPresentationContextProviding)? = nil
    ) -> AsyncThrowingStream<URL, any Error> {
        AsyncThrowingStream<URL, any Error>(bufferingPolicy: .unbounded) { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackURLScheme,
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
            #if !DEBUG
            session.prefersEphemeralWebBrowserSession = true
            #endif
            continuation.onTermination = { @Sendable _ in
                session.cancel()
            }
            session.presentationContextProvider = presentationContextProvider
            session.start()
        }
    }
}
