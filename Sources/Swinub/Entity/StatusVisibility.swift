import Foundation

public struct StatusVisibility: Codable, Sendable, Equatable, Hashable {
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

public extension StatusVisibility {
    static var personal: Self { .init(rawValue: "personal") }  // fedibird
    static var `direct`: Self { .init(rawValue: "direct") }
    static var `private`: Self { .init(rawValue: "private") }
    static var limited: Self { .init(rawValue: "limited") }  // fedibird
    static var mutualFollowersOnly: Self { .init(rawValue: "mutual") }  // fedibird

    // https://github.com/kmycode/mastodon/wiki/ログインユーザーのみ公開API
    static var login: Self { .init(rawValue: "login") }  // kmy.blue

    static var unlisted: Self { .init(rawValue: "unlisted") }

    // https://github.com/kmycode/mastodon/wiki/ローカル公開API
    static var publicUnlisted: Self { .init(rawValue: "public_unlisted") }  // kmy.blue

    static var `public`: Self { .init(rawValue: "public") }
}

