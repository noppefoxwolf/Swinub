import Foundation

public struct MediaAttachment: Codable, Identifiable, Sendable {
    public let id: ID
    public let type: MediaAttachmentType

    public var url: URL?
    public var previewUrl: URL?
    public let remoteUrl: URL?
    public let description: String?
    public let blurhash: String?
    // fedibirdのmisskeyの投稿などはmetaがnullになることがある
    public let meta: Meta?

    public struct Meta: Codable, Sendable {

        public let original: MetaItem?
        public let small: MetaItem?
        public let tiny: MetaItem?

        public struct MetaItem: Codable, Sendable {
            public let width: Int?
            public let height: Int?
            public let size: String?
            public let aspect: Double?
        }
    }

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
