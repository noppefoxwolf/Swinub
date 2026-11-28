import ArgumentParser
import Foundation
import Swinub

struct Post: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "post",
        abstract: "Create a status."
    )

    @Option(help: "Instance host, for example mastodon.social. Defaults to the active account's host.")
    var host: String?

    @Option(help: "OAuth access token. Defaults to SWINUB_ACCESS_TOKEN or the active Keychain account.")
    var accessToken: String?

    @Option(help: "Status text.")
    var status: String

    @Option(help: "Status visibility.")
    var visibility: String?

    @Flag(help: "Print raw JSON.")
    var json = false

    mutating func run() async throws {
        let authorization = try await AuthStore().resolveAuthorization(
            host: host,
            accessToken: accessToken
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
