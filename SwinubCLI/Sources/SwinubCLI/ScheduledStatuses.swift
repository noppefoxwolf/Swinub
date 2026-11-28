import ArgumentParser
import Foundation
import Swinub

struct ScheduledStatuses: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "scheduled-statuses",
        abstract: "Manage scheduled statuses.",
        subcommands: [List.self, Get.self, Update.self, Cancel.self],
        defaultSubcommand: List.self
    )

    struct List: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "list",
            abstract: "List scheduled statuses."
        )

        @Option(help: "Instance host, for example mastodon.social. Defaults to the active account's host.")
        var host: String?

        @Option(help: "OAuth access token. Defaults to SWINUB_ACCESS_TOKEN or the active Keychain account.")
        var accessToken: String?

        @Option(help: "Maximum number of scheduled statuses to fetch.")
        var limit: Int?

        @Option(help: "Fetch scheduled statuses older than this ID.")
        var maxID: String?

        @Option(help: "Fetch scheduled statuses newer than this ID.")
        var minID: String?

        @Option(help: "Fetch scheduled statuses newer than this ID (since_id).")
        var sinceID: String?

        @Flag(help: "Print raw JSON.")
        var json = false

        mutating func run() async throws {
            let authorization = try await AuthStore().resolveAuthorization(
                host: host,
                accessToken: accessToken
            )
            let statuses = try await SwinubDefaults.session.response(
                for: GetV1ScheduledStatuses(
                    authorization: authorization,
                    maxID: maxID.map(ScheduledStatus.ID.init(rawValue:)),
                    sinceID: sinceID.map(ScheduledStatus.ID.init(rawValue:)),
                    minID: minID.map(ScheduledStatus.ID.init(rawValue:)),
                    limit: limit
                )
            ).response

            if json {
                try printScheduledJSON(statuses)
            } else {
                for status in statuses {
                    printScheduledText(status)
                    print("")
                }
            }
        }
    }

    struct Get: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "get",
            abstract: "Fetch a single scheduled status."
        )

        @Option(help: "Instance host, for example mastodon.social. Defaults to the active account's host.")
        var host: String?

        @Option(help: "OAuth access token. Defaults to SWINUB_ACCESS_TOKEN or the active Keychain account.")
        var accessToken: String?

        @Option(help: "Scheduled status ID.")
        var id: String

        @Flag(help: "Print raw JSON.")
        var json = false

        mutating func run() async throws {
            let authorization = try await AuthStore().resolveAuthorization(
                host: host,
                accessToken: accessToken
            )
            let status = try await SwinubDefaults.session.response(
                for: GetV1ScheduledStatus(
                    id: ScheduledStatus.ID(rawValue: id),
                    authorization: authorization
                )
            ).response

            if json {
                try printScheduledJSON(status)
            } else {
                printScheduledText(status)
            }
        }
    }

    struct Update: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "update",
            abstract: "Update a scheduled status's publishing date."
        )

        @Option(help: "Instance host, for example mastodon.social. Defaults to the active account's host.")
        var host: String?

        @Option(help: "OAuth access token. Defaults to SWINUB_ACCESS_TOKEN or the active Keychain account.")
        var accessToken: String?

        @Option(help: "Scheduled status ID.")
        var id: String

        @Option(help: "New ISO 8601 datetime at which the status will be published.")
        var scheduledAt: String

        @Flag(help: "Print raw JSON.")
        var json = false

        mutating func run() async throws {
            let date = try parseISO8601Date(scheduledAt)
            let authorization = try await AuthStore().resolveAuthorization(
                host: host,
                accessToken: accessToken
            )
            let status = try await SwinubDefaults.session.response(
                for: PutV1ScheduledStatus(
                    id: ScheduledStatus.ID(rawValue: id),
                    scheduledAt: date,
                    authorization: authorization
                )
            ).response

            if json {
                try printScheduledJSON(status)
            } else {
                printScheduledText(status)
            }
        }
    }

    struct Cancel: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "cancel",
            abstract: "Cancel a scheduled status."
        )

        @Option(help: "Instance host, for example mastodon.social. Defaults to the active account's host.")
        var host: String?

        @Option(help: "OAuth access token. Defaults to SWINUB_ACCESS_TOKEN or the active Keychain account.")
        var accessToken: String?

        @Option(help: "Scheduled status ID.")
        var id: String

        mutating func run() async throws {
            let authorization = try await AuthStore().resolveAuthorization(
                host: host,
                accessToken: accessToken
            )
            _ = try await SwinubDefaults.session.response(
                for: DeleteV1ScheduledStatus(
                    id: ScheduledStatus.ID(rawValue: id),
                    authorization: authorization
                )
            )
            print("Cancelled scheduled status \(id).")
        }
    }
}

func parseISO8601Date(_ value: String) throws -> Date {
    let withFractionalSeconds = ISO8601DateFormatter()
    withFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = withFractionalSeconds.date(from: value) {
        return date
    }

    let withoutFractionalSeconds = ISO8601DateFormatter()
    withoutFractionalSeconds.formatOptions = [.withInternetDateTime]
    if let date = withoutFractionalSeconds.date(from: value) {
        return date
    }

    throw ValidationError("Invalid ISO 8601 datetime: \(value)")
}

private func printScheduledJSON<T: Encodable>(_ value: T) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(value)
    guard let json = String(data: data, encoding: .utf8) else {
        throw ValidationError("Failed to encode scheduled status as JSON.")
    }
    print(json)
}

private func printScheduledText(_ status: ScheduledStatus) {
    print("[\(status.id.rawValue)] \(status.scheduledAt)")
    if let spoilerText = status.params.spoilerText, !spoilerText.isEmpty {
        print("CW: \(spoilerText)")
    }
    print(status.params.text)
}
