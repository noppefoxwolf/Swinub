import Foundation

public struct StatusVisibility: Codable, Sendable, Equatable, Hashable {
    public let rawValue: String

    public static var personal: Self { .init(rawValue: "personal") }  // fedibird
    public static var `direct`: Self { .init(rawValue: "direct") }
    public static var `private`: Self { .init(rawValue: "private") }
    public static var limited: Self { .init(rawValue: "limited") }  // fedibird
    public static var mutualFollowersOnly: Self { .init(rawValue: "mutual") }  // fedibird

    // https://github.com/kmycode/mastodon/wiki/ログインユーザーのみ公開API
    public static var login: Self { .init(rawValue: "login") }  // kmy.blue

    public static var unlisted: Self { .init(rawValue: "unlisted") }

    // https://github.com/kmycode/mastodon/wiki/ローカル公開API
    public static var publicUnlisted: Self { .init(rawValue: "public_unlisted") }  // kmy.blue

    public static var `public`: Self { .init(rawValue: "public") }

    // 標準のmastodonでサポートしている公開範囲
    public static var defaultCases: [Self] {
        [.direct, .private, .unlisted, .public]
    }

    // 公開範囲の狭い順
    public static var allCases: [Self] {
        [
            .personal, .direct, .private, .limited, .mutualFollowersOnly, .login, .unlisted,
            .publicUnlisted, .public,
        ]
    }

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

extension StatusVisibility: Comparable {
    public static func < (lhs: StatusVisibility, rhs: StatusVisibility) -> Bool {
        let lhsIndex = Self.allCases.firstIndex(of: lhs) ?? 0
        let rhsIndex = Self.allCases.firstIndex(of: rhs) ?? 0
        return lhsIndex < rhsIndex
    }
}
