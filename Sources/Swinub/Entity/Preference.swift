public struct Preference: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case postingDefaultVisibility = "posting:default:visibility"
        case postingDefaultSensitive = "posting:default:sensitive"
        case postingDefaultLanguage = "posting:default:language"
        // Added by Mastodon API Version 7
        case postingDefaultQuotePolicy = "posting:default:quote_policy"
        case readingExpandMedia = "reading:expand:media"
        case readingExpandSpoilers = "reading:expand:spoilers"
        case readingAutoplayGifs = "reading:autoplay:gifs"
    }
    public let postingDefaultVisibility: StatusVisibility?
    public let postingDefaultSensitive: Bool?
    public let postingDefaultLanguage: String?
    // Added by Mastodon API Version 7
    public let postingDefaultQuotePolicy: QuoteApprovalPolicy?
    public let readingExpandMedia: String?
    public let readingExpandSpoilers: Bool?
    public let readingAutoplayGifs: Bool?
}
