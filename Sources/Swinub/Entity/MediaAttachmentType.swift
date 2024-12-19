public struct MediaAttachmentType: Codable, Sendable, Equatable {
    public let rawValue: String
    
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
    
    static var unknown: Self { .init(rawValue: "unknown") }
    static var image: Self { .init(rawValue: "image") }
    static var gifv: Self { .init(rawValue: "gifv") }
    static var video: Self { .init(rawValue: "video") }
    static var audio: Self { .init(rawValue: "audio") }
}
