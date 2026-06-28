import ArgumentParser
import Foundation
import Swinub

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
