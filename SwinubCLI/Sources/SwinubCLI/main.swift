import ArgumentParser
import Foundation
import Swinub
import SwinubAuthenticationServices

@main
struct SwinubCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "SwinubCLI",
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

    mutating func run() async throws {
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

struct ScopeList: CustomStringConvertible, ExpressibleByArgument {
    let scopes: [Scope]
    var description: String {
        scopes.map(\.rawValue).joined(separator: ",")
    }

    init(scopes: [Scope]) {
        self.scopes = scopes
    }

    init?(argument: String) {
        let values = argument.split(separator: ",").map {
            String($0).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let scopes = values.compactMap(Scope.init(rawValue:))

        guard scopes.count == values.count else {
            return nil
        }

        self.scopes = scopes.isEmpty ? [.read] : scopes
    }
}
