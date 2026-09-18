import ArgumentParser
import Foundation
import Swinub

struct Edit: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "edit",
        abstract: "Edit a status."
    )

    @Option(help: "Instance host, for example mastodon.social.")
    var host: String

    @Option(help: "OAuth access token. Defaults to SWINUB_ACCESS_TOKEN.")
    var accessToken: String?

    @Option(help: "Status ID to edit.")
    var statusID: String

    @Option(help: "Edited status text. Omit to leave it unchanged.")
    var status: String?

    @Option(help: "Content warning. Pass an empty value to clear it.")
    var spoilerText: String?

    @Flag(inversion: .prefixedNo, help: "Mark the status as sensitive or not sensitive.")
    var sensitive: Bool?

    @Option(help: "ISO 639-1 language code.")
    var language: String?

    @Flag(help: "Print raw JSON.")
    var json = false

    mutating func run() async throws {
        guard status != nil || spoilerText != nil || sensitive != nil || language != nil else {
            throw ValidationError("Pass at least one edit option.")
        }

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
        var parameters = PutV1Statuses.Parameters()
        parameters.status = status
        parameters.spoilerText = spoilerText
        parameters.sensitive = sensitive
        parameters.language = language.map(Locale.Language.init(identifier:))

        let editedStatus = try await SwinubDefaults.session.response(
            for: PutV1Statuses(
                statusID: Status.ID(rawValue: statusID),
                parameters: parameters,
                authorization: authorization
            )
        ).response

        if json {
            try printJSON(editedStatus)
        } else {
            print(editedStatus.id.rawValue)
            if let url = editedStatus.url {
                print(url.absoluteString)
            }
        }
    }

    private func resolvedAccessToken() throws -> String {
        let token = accessToken ?? ProcessInfo.processInfo.environment["SWINUB_ACCESS_TOKEN"]
        guard let token, !token.isEmpty else {
            throw ValidationError("Missing access token. Pass --access-token or set SWINUB_ACCESS_TOKEN.")
        }
        return token
    }

    private func printJSON(_ status: Status) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(status)
        guard let json = String(data: data, encoding: .utf8) else {
            throw ValidationError("Failed to encode status as JSON.")
        }
        print(json)
    }
}
