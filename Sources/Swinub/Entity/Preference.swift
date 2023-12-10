public struct Preference: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case postingDefaultVisibility = "posting:default:visibility"
        case postingDefaultSensitive = "posting:default:sensitive"
        case postingDefaultLanguage = "posting:default:language"
        case readingExpandMedia = "reading:expand:media"
        case readingExpandSpoilers = "reading:expand:spoilers"
        case readingAutoplayGifs = "reading:autoplay:gifs"
    }
    public let postingDefaultVisibility: String?
    public let postingDefaultSensitive: Bool?
    public let postingDefaultLanguage: String?
    public let readingExpandMedia: String?
    public let readingExpandSpoilers: Bool?
    public let readingAutoplayGifs: Bool?
}
