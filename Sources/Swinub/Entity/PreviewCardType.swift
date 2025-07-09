public struct PreviewCardType: Codable, Sendable, Equatable {
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

    public static var link: Self { Self.init(rawValue: "link") }
    public static var photo: Self { Self.init(rawValue: "photo") }
    public static var video: Self { Self.init(rawValue: "video") }
    public static var rich: Self { Self.init(rawValue: "rich") }
}
