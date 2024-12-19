public struct FilterContextV1: Codable, Sendable, Equatable, Hashable {
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
    
    public static var home: Self { Self.init(rawValue: "home") }
    public static var notifications: Self { Self.init(rawValue: "notifications") }
    public static var `public`: Self { Self.init(rawValue: "public") }
    public static var thread: Self { Self.init(rawValue: "thread") }
    public static var account: Self { Self.init(rawValue: "account") }
}
