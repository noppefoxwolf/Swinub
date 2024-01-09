import Foundation
import os

fileprivate let logger = Logger(
    subsystem: "dev.noppe.swinub.logger",
    category: #file
)

public enum StatusVisibility: RawRepresentable, Codable, Sendable, Equatable, Hashable,
    Comparable
{

    public init(rawValue: String) {
        switch rawValue {
        case Self.personal.rawValue:
            self = .personal
        case Self.direct.rawValue:
            self = .direct
        case Self.private.rawValue:
            self = .private
        case Self.limited.rawValue:
            self = .limited
        case Self.mutualFollowersOnly.rawValue:
            self = .mutualFollowersOnly
        case Self.publicUnlisted.rawValue:
            self = .publicUnlisted
        case Self.login.rawValue:
            self = .login
        case Self.unlisted.rawValue:
            self = .unlisted
        case Self.public.rawValue:
            self = .public
        default:
            logger.debug("custom \(rawValue)")
            self = .custom(rawValue)
        }
    }

    // 公開範囲の狭い順
    case personal  // fedibird
    case `direct`
    case `private`
    case limited  // fedibird
    case mutualFollowersOnly  // fedibird
    case custom(String)

    // https://github.com/kmycode/mastodon/wiki/ログインユーザーのみ公開API
    case login  // kmy.blue

    case `unlisted`

    // https://github.com/kmycode/mastodon/wiki/ローカル公開API
    case publicUnlisted  // kmy.blue

    case `public`

    public var rawValue: String {
        switch self {
        case .public:
            return "public"
        case .unlisted:
            return "unlisted"
        case .private:
            return "private"
        case .direct:
            return "direct"
        case .limited:
            return "limited"
        case .personal:
            return "personal"
        case .mutualFollowersOnly:
            return "mutual"
        case .publicUnlisted:
            return "public_unlisted"
        case .login:
            return "login"
        case .custom(let string):
            return string
        }
    }

    public static var defaultCases: [Self] {
        [.direct, .private, .unlisted, .public]
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
        case .custom:
            return "questionmark.bubble"
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(rawValue: rawValue)
    }
}
