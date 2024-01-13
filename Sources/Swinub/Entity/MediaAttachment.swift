import Foundation

public struct MediaAttachment: Codable, Identifiable, Sendable {
    public let id: ID
    public let type: MediaAttachmentType

    public var url: URL?
    public var previewUrl: URL?
    public let remoteUrl: URL?
    //    public let meta: String
    public let description: String?
    public let blurhash: String
    
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

public enum MediaAttachmentType: String, Codable, Sendable {
    case unknown
    case image
    case gifv
    case video
    case audio
}
