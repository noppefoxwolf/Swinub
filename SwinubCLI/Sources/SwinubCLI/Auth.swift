import ArgumentParser
import Foundation
import Swinub
import SwinubAuthenticationServices

struct Auth: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "auth",
        abstract: "Authorize a Fediverse account and print an access token."
    )

    @Option(help: "Instance host, for example mastodon.social.")
    var host: String

    @Option(help: "Application name to register with the instance.")
    var clientName = "SwinubCLI"

    @Option(help: "Comma-separated OAuth scopes: read,write,follow,push.")
    var scopes = ScopeList(scopes: [.read])

    @Flag(help: "Open the authorization URL in the default browser.")
    var open = false

    @Option(help: "Use a local redirect callback on this port instead of OAuth out-of-band.")
    var callbackPort: UInt16?

    @Option(help: "Local redirect callback path.")
    var callbackPath = "/callback"

    mutating func run() async throws {
        if let callbackPort {
            try await runLocalRedirectAuth(callbackPort: callbackPort)
            return
        }

        let service = OAuthOutOfBandAuthenticationService()
        let authorizationRequest = try await service.makeAuthorizationRequest(
            host: host,
            clientName: clientName,
            scopes: scopes.scopes
        )

        print("Open this URL and authorize the app:")
        print(authorizationRequest.authorizationURL.absoluteString)

        if open {
            try openInBrowser(authorizationRequest.authorizationURL)
        }

        print("")
        print("Paste authorization code: ", terminator: "")
        guard let code = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
            !code.isEmpty
        else {
            throw ValidationError("Authorization code is empty.")
        }

        let token = try await service.exchangeCode(code, for: authorizationRequest)
        print(token.accessToken)
    }

    private func runLocalRedirectAuth(callbackPort: UInt16) async throws {
        let redirectURI = "http://127.0.0.1:\(callbackPort)\(normalizedCallbackPath())"
        let application = try await SwinubDefaults.session.response(
            for: PostV1Apps(
                host: host,
                clientName: clientName,
                redirectURI: redirectURI,
                scopes: scopes.scopes
            )
        ).response

        let authorizationURL = try WebAuthenticationSessionDataFactory(
            host: host,
            clientId: application.clientId,
            redirectUri: redirectURI,
            scopes: scopes.scopes
        ).makeURL()
        let callbackServer = try LocalOAuthCallbackServer(
            port: callbackPort,
            path: normalizedCallbackPath()
        )

        print("Open this URL and authorize the app:")
        print(authorizationURL.absoluteString)
        print("")
        print("Waiting for callback on \(redirectURI)")

        if open {
            try openInBrowser(authorizationURL)
        }

        let code = try await callbackServer.waitForCode()
        let token = try await SwinubDefaults.session.response(
            for: PostOAuthToken(
                host: host,
                clientId: application.clientId,
                clientSecret: application.clientSecret,
                redirectUri: redirectURI,
                code: code,
                scopes: scopes.scopes
            )
        ).response
        print(token.accessToken)
    }

    private func normalizedCallbackPath() -> String {
        callbackPath.hasPrefix("/") ? callbackPath : "/\(callbackPath)"
    }

    private func openInBrowser(_ url: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [url.absoluteString]
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ValidationError("Failed to open browser.")
        }
    }
}
