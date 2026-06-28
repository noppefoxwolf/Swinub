import ArgumentParser
import Foundation
import Swinub
import SwinubAuthenticationServices

@main
struct SwinubCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swinub-cli",
        abstract: "Utilities for working with Swinub.",
        subcommands: [Auth.self, Mentions.self]
    )
}

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

struct Mentions: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mentions",
        abstract: "Fetch mention notifications."
    )

    @Option(help: "Instance host, for example mastodon.social.")
    var host: String

    @Option(help: "OAuth access token. Defaults to SWINUB_ACCESS_TOKEN.")
    var accessToken: String?

    @Option(help: "Maximum number of mentions to fetch.")
    var limit = 30

    @Option(help: "Fetch notifications older than this notification ID.")
    var maxID: String?

    @Option(help: "Fetch notifications newer than this notification ID.")
    var minID: String?

    @Flag(help: "Print raw JSON.")
    var json = false

    mutating func run() async throws {
        let token = try resolvedAccessToken()
        let placeholderAuthorization = Authorization(
            host: host,
            accountID: Account.ID(rawValue: ""),
            oauthToken: token
        )
        let account = try await SwinubDefaults.session.response(
            for: GetV1AccountsVerifyCredentials(authorization: placeholderAuthorization)
        ).response

        let authorization = Authorization(
            host: host,
            accountID: account.id,
            oauthToken: token
        )
        var request = GetV1Notifications(authorization: authorization)
        request.limit = limit
        request.types = ["mention"]
        request.maxID = maxID.map(Notification.ID.init(rawValue:))
        request.minID = minID.map(Notification.ID.init(rawValue:))

        let mentions = try await SwinubDefaults.session.response(for: request).response

        if json {
            try printJSON(mentions)
        } else {
            printText(mentions)
        }
    }

    private func resolvedAccessToken() throws -> String {
        let token = accessToken ?? ProcessInfo.processInfo.environment["SWINUB_ACCESS_TOKEN"]
        guard let token, !token.isEmpty else {
            throw ValidationError("Missing access token. Pass --access-token or set SWINUB_ACCESS_TOKEN.")
        }
        return token
    }

    private func printJSON(_ mentions: [Swinub.Notification]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(mentions)
        guard let json = String(data: data, encoding: .utf8) else {
            throw ValidationError("Failed to encode mentions as JSON.")
        }
        print(json)
    }

    private func printText(_ mentions: [Swinub.Notification]) {
        for mention in mentions {
            let account = mention.account
            let status = mention.status
            let displayName = account.displayName.isEmpty ? account.acct : account.displayName

            print("[\(mention.id.rawValue)] \(mention.createdAt)")
            print("@\(account.acct) \(displayName)")
            if let status {
                print(stripHTML(status.content))
                if let url = status.url {
                    print(url.absoluteString)
                }
            }
            print("")
        }
    }

    private func stripHTML(_ html: String) -> String {
        var result = ""
        var isInsideTag = false

        for character in html {
            switch character {
            case "<":
                isInsideTag = true
            case ">":
                isInsideTag = false
            default:
                if !isInsideTag {
                    result.append(character)
                }
            }
        }

        return result
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
