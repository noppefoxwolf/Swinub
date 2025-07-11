import Foundation

public struct StatusVisibility: Codable, Sendable, Equatable, Hashable {
    public let rawValue: String

    public static let personal = StatusVisibility(rawValue: "personal")  // fedibird
    public static let `direct` = StatusVisibility(rawValue: "direct")
    public static let `private` = StatusVisibility(rawValue: "private")
    public static let limited = StatusVisibility(rawValue: "limited")  // fedibird
    public static let mutualFollowersOnly = StatusVisibility(rawValue: "mutual")  // fedibird

    // https://github.com/kmycode/mastodon/wiki/ログインユーザーのみ公開API
    public static let login = StatusVisibility(rawValue: "login")  // kmy.blue

    public static let unlisted = StatusVisibility(rawValue: "unlisted")

    // https://github.com/kmycode/mastodon/wiki/ローカル公開API
    public static let publicUnlisted = StatusVisibility(rawValue: "public_unlisted")  // kmy.blue

    public static let `public` = StatusVisibility(rawValue: "public")

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

    public var systemSymbolName: String {
        switch self {
        case .public:
            return "globe.asia.australia.fill"
        case .unlisted:
            return "lock.open.fill"
        case .private:
            return "lock.fill"
        case .direct:
            return "at"
        case .mutualFollowersOnly:
            return "arrow.left.arrow.right"
        case .personal:
            return "text.book.closed"
        case .limited:
            return "person.crop.circle"
        case .login:
            return "key"
        case .publicUnlisted:
            return "cloud"
        default:
            return "questionmark.bubble"
        }
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
