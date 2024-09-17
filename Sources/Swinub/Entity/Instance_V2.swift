public struct Instance: Codable, Sendable {
    public let domain: String
    public let title: String
    public let version: String
    public let description: String
    public let rules: [Rule]
    public let configuration: InstanceConfiguration
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
    public let statuses: InstanceStatusesConfiguration
    public let mediaAttachments: InstanceMediaAttachmentsConfiguration
    public let polls: InstancePollsConfiguration
    // fedibird拡張
    public let search: InstanceSearchConfiguration?
    // firefish拡張
    public let reactions: InstanceReactionsConfiguration?
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
