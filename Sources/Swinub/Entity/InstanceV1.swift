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

    // Fedibirdでのみ返る
    // https://github.com/fedibird/mastodon/blob/main/app/serializers/rest/instance_serializer.rb#L107
    public let fedibirdCapabilities: [String]?
}

extension InstanceV1 {
    public struct URLs: Codable, Sendable {
        public let streamingApi: String?
    }
}
