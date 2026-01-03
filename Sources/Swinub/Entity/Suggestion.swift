

public struct Suggestion: Codable, Sendable {
    public let source: SuggestionSource
    public let sources: [SuggestionSource]?
    public let account: Account
}

public struct SuggestionSource: Codable, Sendable {
    public let rawValue: String
    
    init(rawValue: String) {
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
    
    /// This account was manually recommended by the administration team
    public static var staff: Self {
        Self(rawValue: "staff")
    }
    
    /// The authenticated account has interacted with this account previously
    public static var pastInteractions: Self {
        Self(rawValue: "past_interactions")
    }
    
    /// This account has many reblogs, favourites, and active local followers within the last 30 days
    public static var global: Self {
        Self(rawValue: "global")
    }
    
    /// This account was manually recommended by the administration team. Equivalent to the staff value for source
    public static var featured: Self {
        Self(rawValue: "featured")
    }
    
    /// This account has many active local followers
    public static var mostFollowed: Self {
        Self(rawValue: "most_followed")
    }
    
    /// This account had many reblogs and favourites within the last 30 days
    public static var mostInteractions: Self {
        Self(rawValue: "most_interactions")
    }
    
    /// This account’s profile is similar to the authenticated account’s most recent follows
    public static var similarToRecentlyFollowed: Self {
        Self(rawValue: "similar_to_recently_followed")
    }
    
    /// This account is followed by people followed by the authenticated account
    public static var friendsOfFriends: Self {
        Self(rawValue: "friends_of_friends")
    }
}
