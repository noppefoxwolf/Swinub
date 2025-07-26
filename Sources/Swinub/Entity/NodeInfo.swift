public struct NodeInfo: Codable, Sendable {
    public let version: String
    public let openRegistrations: Bool
    public let usage: Usage
    public let metadata: Metadata

    public struct Usage: Codable, Sendable {
        public let users: Users

        public struct Users: Codable, Sendable {
            public let total: Int
            public let activeHalfyear: Int
            public let activeMonth: Int
        }
    }

    public struct Metadata: Codable, Sendable {
        public let nodeName: String?
        public let nodeDescription: String?
    }
}
