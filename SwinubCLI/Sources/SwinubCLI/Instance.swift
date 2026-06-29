import ArgumentParser
import Foundation
import Swinub

struct Instance: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "instance",
        abstract: "Fetch instance metadata."
    )

    @Option(help: "Instance host, for example mastodon.social.")
    var host: String

    @Flag(help: "Print raw JSON.")
    var json = false

    mutating func run() async throws {
        let instance = try await SwinubDefaults.session.response(
            for: GetV2Instance(host: host)
        ).response

        if json {
            try printJSON(instance)
        } else {
            printText(instance)
        }
    }

    private func printJSON(_ instance: InstanceV2) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(instance)
        guard let json = String(data: data, encoding: .utf8) else {
            throw ValidationError("Failed to encode instance as JSON.")
        }
        print(json)
    }

    private func printText(_ instance: InstanceV2) {
        print("domain: \(instance.domain)")
        print("title: \(instance.title)")
        print("version: \(instance.version)")

        if let mastodonAPIVersion = instance.apiVersions?.mastodon {
            print("api_versions.mastodon: \(mastodonAPIVersion)")
        }

        if let capabilities = instance.fedibirdCapabilities, !capabilities.isEmpty {
            let values = capabilities.map(fedibirdCapabilityValue).joined(separator: ", ")
            print("fedibird_capabilities: \(values)")
        }

        print("max_characters: \(instance.configuration.statuses.maxCharacters)")
        print("max_media_attachments: \(instance.configuration.statuses.maxMediaAttachments)")
        print("registrations_enabled: \(instance.registrations.enabled)")
        print("approval_required: \(instance.registrations.approvalRequired)")
    }

    private func fedibirdCapabilityValue(
        _ capability: NonFrozenEnum<FedibirdCapability>
    ) -> String {
        switch capability {
        case .value(let value):
            value.rawValue
        case .unknown(let value):
            value
        }
    }
}
