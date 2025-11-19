public struct InstanceV2: Codable, Sendable {
    public let domain: String
    public let title: String
    public let version: String
    public let description: String
    public let thumbnail: Thumbnail
    public let rules: [Rule]
    public let configuration: InstanceConfiguration
    public let contact: Contact
    public let registrations: Registrations
    // Added Mastodon 4.3
    public let apiVersions: APIVersions?
    public let fedibirdCapabilities: [NonFrozenEnum<FedibirdCapability>]?
}

public struct APIVersions: Codable, Sendable {
    // Added Mastodon 4.3
    public let mastodon: Int
}

public struct Usage: Codable, Sendable {
    public struct Users: Codable, Sendable {
        public let activeMonth: Bool
    }
    public let users: Users
}

public struct Registrations: Codable, Sendable {
    public let enabled: Bool
    public let approvalRequired: Bool
    public let reasonRequired: Bool?
    public let message: String?
    public let url: String?
}

public struct Contact: Codable, Sendable {
    public let email: String
    public let account: Account
}

public struct Thumbnail: Codable, Sendable {
    public let url: String
    public let blurhash: String?
}

public struct Rule: Codable, Sendable {
    public let id: ID
    public let text: String

    public struct ID: Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
        public let rawValue: String
        public var description: String { rawValue }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.rawValue = try container.decode(String.self)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }
}

public struct Stats: Codable, Sendable {
    public let userCount: Int
    public let statusCount: Int
    public let domainCount: Int
}

// https://fedibird.com/api/v1/instance
public struct InstanceConfiguration: Codable, Sendable {
    public let accounts: InstanceAccountsConfiguration
    public let statuses: InstanceStatusesConfiguration
    public let mediaAttachments: InstanceMediaAttachmentsConfiguration
    public let polls: InstancePollsConfiguration
    
    /// api/v2/instance only
    public let urls: InstanceURLsConfiguration?
    // fedibird拡張
    public let search: InstanceSearchConfiguration?
    // firefish拡張
    public let reactions: InstanceReactionsConfiguration?
}

public struct InstanceURLsConfiguration: Codable, Sendable {
    public let streaming: String
}

public struct InstanceAccountsConfiguration: Codable, Sendable {
    public let maxFeaturedTags: Int
}

public struct InstanceStatusesConfiguration: Codable, Sendable {
    public let maxCharacters: Int
    public let maxMediaAttachments: Int
}

public struct InstanceMediaAttachmentsConfiguration: Codable, Sendable {
    public let supportedMimeTypes: [String]
    public let imageSizeLimit: Int
    public let imageMatrixLimit: Int
    public let videoSizeLimit: Int
    // IceShrinp系ではvideoFrameRateLimitの代わりにvideoFrameLimitが採用されているケースがある
    // https://rindo.garden/api/v1/instance
    public let videoFrameLimit: Int?
    public let videoFrameRateLimit: Int?
    public let videoMatrixLimit: Int
}

public struct InstancePollsConfiguration: Codable, Sendable {
    public let maxOptions: Int
    public let maxCharactersPerOption: Int
    public let minExpiration: Int
    public let maxExpiration: Int
}

public struct InstanceSearchConfiguration: Codable, Sendable {
    // fedibird拡張ではあるが、同じキーがあるとは限らないので念の為optionalにしている
    public let supportedPrefix: [String]?
}

public struct InstanceReactionsConfiguration: Codable, Sendable {
    // firefish拡張ではあるが、同じキーがあるとは限らないので念の為optionalにしている
    public let maxReactions: Int?
    public let defaultReaction: String?
}
