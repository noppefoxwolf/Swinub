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

    @Option(help: "Instance API version: auto, v1, or v2.")
    var apiVersion = InstanceAPIVersion.auto

    @Flag(help: "Print raw JSON.")
    var json = false

    mutating func run() async throws {
        switch try await fetchInstance() {
        case .v1(let instance):
            if json {
                try printJSON(instance)
            } else {
                printText(instance)
            }
        case .v2(let instance):
            if json {
                try printJSON(instance)
            } else {
                printText(instance)
            }
        }
    }

    private func fetchInstance() async throws -> InstanceResponse {
        switch apiVersion {
        case .auto:
            do {
                return .v2(try await fetchV2Instance())
            } catch let error as SwinubError where error.httpResponse.status.code == 404 {
                return .v1(try await fetchV1Instance())
            }
        case .v1:
            return .v1(try await fetchV1Instance())
        case .v2:
            return .v2(try await fetchV2Instance())
        }
    }

    private func fetchV1Instance() async throws -> InstanceV1 {
        try await SwinubDefaults.session.response(
            for: GetV1Instance(host: host)
        ).response
    }

    private func fetchV2Instance() async throws -> InstanceV2 {
        try await SwinubDefaults.session.response(
            for: GetV2Instance(host: host)
        ).response
    }

    private func printJSON<T: Encodable>(_ instance: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(instance)
        guard let json = String(data: data, encoding: .utf8) else {
            throw ValidationError("Failed to encode instance as JSON.")
        }
        print(json)
    }

    private func printText(_ instance: InstanceV1) {
        print("domain: \(instance.uri)")
        print("title: \(instance.title)")
        print("version: \(instance.version)")

        if let capabilities = instance.fedibirdCapabilities, !capabilities.isEmpty {
            let values = capabilities.map(fedibirdCapabilityValue).joined(separator: ", ")
            print("fedibird_capabilities: \(values)")
        }

        if let configuration = instance.configuration {
            print("max_characters: \(configuration.statuses.maxCharacters)")
            print("max_media_attachments: \(configuration.statuses.maxMediaAttachments)")
        }

        if let registrations = instance.registrations {
            print("registrations_enabled: \(registrations)")
        }

        if let approvalRequired = instance.approvalRequired {
            print("approval_required: \(approvalRequired)")
        }
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

private enum InstanceResponse {
    case v1(InstanceV1)
    case v2(InstanceV2)
}

enum InstanceAPIVersion: String, ExpressibleByArgument {
    case auto
    case v1
    case v2

    init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}
