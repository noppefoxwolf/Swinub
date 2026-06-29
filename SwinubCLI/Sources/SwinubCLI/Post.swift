import ArgumentParser
import Foundation
import Swinub

struct Post: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "post",
        abstract: "Create a status."
    )

    @Option(help: "Instance host, for example mastodon.social.")
    var host: String

    @Option(help: "OAuth access token. Defaults to SWINUB_ACCESS_TOKEN.")
    var accessToken: String?

    @Option(help: "Status text.")
    var status: String

    @Option(help: "Status visibility.")
    var visibility: String?

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
        var parameters = PostV1Statuses.Parameters()
        parameters.status = status
        parameters.visibility = visibility.map(StatusVisibility.init(rawValue:))

        let createdStatus = try await SwinubDefaults.session.response(
            for: PostV1Statuses(parameters: parameters, authorization: authorization)
        ).response

        if json {
            try printJSON(createdStatus)
        } else {
            print(createdStatus.id.rawValue)
            if let url = createdStatus.url {
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
