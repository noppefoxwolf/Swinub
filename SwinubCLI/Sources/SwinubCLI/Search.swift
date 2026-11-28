import ArgumentParser
import Foundation
import Swinub

struct Search: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "search",
        abstract: "Search statuses or hashtags."
    )

    @Option(help: "Instance host, for example mastodon.social. Defaults to the active account's host.")
    var host: String?

    @Option(help: "OAuth access token. Defaults to SWINUB_ACCESS_TOKEN or the active Keychain account.")
    var accessToken: String?

    @Option(help: "Search query.")
    var query: String

    @Option(help: "Search type: statuses or hashtags.")
    var type = SearchType.statuses

    @Option(help: "Maximum number of results to fetch.")
    var limit = 20

    @Option(help: "Fetch results older than this ID.")
    var maxID: String?

    @Option(help: "Fetch results newer than this ID.")
    var minID: String?

    @Option(help: "Offset for pagination (hashtags only).")
    var offset: Int?

    @Flag(help: "Attempt WebFinger lookup (statuses only).")
    var resolve = false

    @Flag(help: "Exclude unreviewed tags (hashtags only).")
    var excludeUnreviewed = false

    @Flag(help: "Print raw JSON.")
    var json = false

    mutating func run() async throws {
        let authorization = try await AuthStore().resolveAuthorization(
            host: host,
            accessToken: accessToken
        )

        let result: Swinub.Search
        switch type {
        case .statuses:
            var request = GetV2SearchStatuses(authorization: authorization, q: query)
            request.limit = limit
            request.nextCursor = maxID.map(NextCursor.init(maxID:))
            request.prevCursor = minID.map(PrevCursor.init(minID:))
            request.resolve = resolve
            result = try await SwinubDefaults.session.response(for: request).response
        case .hashtags:
            var request = GetV2SearchHashtags(authorization: authorization, q: query)
            request.limit = limit
            request.offset = offset
            request.excludeUnreviewed = excludeUnreviewed
            request.nextCursor = maxID.map(NextCursor.init(maxID:))
            request.prevCursor = minID.map(PrevCursor.init(minID:))
            result = try await SwinubDefaults.session.response(for: request).response
        }

        if json {
            try printJSON(result)
        } else {
            printText(result)
        }
    }

    private func printJSON(_ result: Swinub.Search) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(result)
        guard let json = String(data: data, encoding: .utf8) else {
            throw ValidationError("Failed to encode search results as JSON.")
        }
        print(json)
    }

    private func printText(_ result: Swinub.Search) {
        switch type {
        case .statuses:
            for status in result.statuses {
                let account = status.account
                let displayName = account.displayName.isEmpty ? account.acct : account.displayName

                print("[\(status.id.rawValue)] \(status.createdAt)")
                print("@\(account.acct) \(displayName)")
                print(stripHTML(status.content))
                if let url = status.url {
                    print(url.absoluteString)
                }
                print("")
            }
        case .hashtags:
            for tag in result.hashtags {
                print("#\(tag.name)")
                if let url = tag.url {
                    print(url.absoluteString)
                }
                print("")
            }
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

enum SearchType: String, ExpressibleByArgument {
    case statuses
    case hashtags

    init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}
