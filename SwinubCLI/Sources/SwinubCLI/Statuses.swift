import ArgumentParser
import Foundation
import Swinub

struct Statuses: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "statuses",
        abstract: "Fetch statuses for an account."
    )

    @Option(help: "Instance host, for example mastodon.social. Defaults to the active account's host.")
    var host: String?

    @Option(help: "OAuth access token. Defaults to SWINUB_ACCESS_TOKEN or the active Keychain account.")
    var accessToken: String?

    @Option(help: "Account handle to look up, for example noppe or @noppe@mastodon.social.")
    var account: String?

    @Option(help: "Account ID to fetch statuses for.")
    var accountID: String?

    @Option(help: "Maximum number of statuses to fetch.")
    var limit = 20

    @Option(help: "Fetch statuses older than this status ID.")
    var maxID: String?

    @Option(help: "Fetch statuses newer than this status ID.")
    var minID: String?

    @Option(help: "Fetch statuses newer than this status ID (since_id).")
    var sinceID: String?

    @Flag(help: "Return only pinned statuses.")
    var pinned = false

    @Flag(help: "Return only statuses with media attachments.")
    var onlyMedia = false

    @Flag(help: "Print raw JSON.")
    var json = false

    mutating func run() async throws {
        guard account != nil || accountID != nil else {
            throw ValidationError("Pass --account or --account-id.")
        }

        let authorization = try await AuthStore().resolveAuthorization(
            host: host,
            accessToken: accessToken
        )

        let targetAccountID: Account.ID
        if let accountID, !accountID.isEmpty {
            targetAccountID = Account.ID(rawValue: accountID)
        } else if let account {
            let normalizedAcct = account.hasPrefix("@") ? String(account.dropFirst()) : account
            guard !normalizedAcct.isEmpty else {
                throw ValidationError("Account handle is empty.")
            }
            let lookedUpAccount = try await SwinubDefaults.session.response(
                for: GetV1AccountsLookup(host: authorization.host, acct: normalizedAcct)
            ).response
            targetAccountID = lookedUpAccount.id
        } else {
            throw ValidationError("Pass --account or --account-id.")
        }

        var request = GetV1AccountStatuses(
            accountID: targetAccountID,
            authorization: authorization
        )
        request.limit = limit
        request.nextCursor = maxID.map(NextCursor.init(maxID:))
        request.prevCursor = minID.map(PrevCursor.init(minID:))
        request.sinceID = sinceID.map(Status.ID.init(rawValue:))
        request.pinned = pinned
        request.onlyMedia = onlyMedia

        let statuses = try await SwinubDefaults.session.response(for: request).response

        if json {
            try printJSON(statuses)
        } else {
            printText(statuses)
        }
    }

    private func printJSON(_ statuses: [Status]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(statuses)
        guard let json = String(data: data, encoding: .utf8) else {
            throw ValidationError("Failed to encode statuses as JSON.")
        }
        print(json)
    }

    private func printText(_ statuses: [Status]) {
        for status in statuses {
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
