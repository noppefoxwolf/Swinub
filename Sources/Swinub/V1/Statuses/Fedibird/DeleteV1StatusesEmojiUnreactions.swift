import Foundation
import HTTPTypes

public struct DeleteV1StatusesEmojiUnreactions: AuthorizationRequest, Sendable {
    public typealias Response = Status

    public struct Emoji: Sendable {
        public init(name: String, domain: String?) {
            self.name = name
            self.domain = domain
        }

        public let name: String
        public let domain: String?

        // emoji@fedibird.com
        var parameterValue: String {
            var emoji = name
            if let domain {
                emoji += "@\(domain)"
            }
            return emoji
        }
    }
    public init(id: Status.ID, emoji: Emoji, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = id
        self.emoji = emoji
    }
    public let authorization: Authorization
    public let statusID: Status.ID
    public let emoji: Emoji
    public var authority: String { authorization.host }
    public let method: RequestMethod = .http(.delete)
    public var path: String {
        let emoji =
            emoji.parameterValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return "/api/v1/statuses/\(statusID)/emoji_reactions/\(emoji)"
    }
}
