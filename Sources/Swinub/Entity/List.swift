public struct List: Codable, Identifiable, Sendable {
    public let id: ID
    public let title: String
    // https://docs.joinmastodon.org/entities/List/#replies_policy
    public let repliesPolicy: String?
    
    public struct ID: Equatable, Hashable, Sendable, Codable {
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
    }
}
