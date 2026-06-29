import Foundation

public struct InstanceV1: Codable, Sendable {
    public let uri: String
    public let title: String
    public let shortDescription: String
    public let description: String
    public let version: String
    public let stats: Stats
    // rulesが返ってこないことがあるのでOptionalにした
    // https://pawoo.net
    public let rules: [Rule]?

    public let urls: URLs?

    public let thumbnail: URL?
    // configurationが返ってこないことがあるのでOptionalにした
    // https://community.4nonome.com/api/v1/instance
    // https://docs.joinmastodon.org/entities/Instance/#configuration
    public let configuration: InstanceConfiguration?

    public let fedibirdCapabilities: [NonFrozenEnum<FedibirdCapability>]?
    // Fedibird quote_id support flag. Mastodon upstream uses quoted_status_id and apiVersions.
    public let featureQuote: Bool?
}

extension InstanceV1 {
    public struct URLs: Codable, Sendable {
        public let streamingApi: String?
    }
}
