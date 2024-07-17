import Foundation
import HTTPTypes

// https://firefish.dev/firefish/firefish/-/merge_requests/11146/diffs#08ccd48c384b5da71ad65facab3d6255ffbb6fb3_5_113
public struct PostV1StatusesReact: HTTPEndpointRequest, Sendable {
    public typealias Response = Status

    public struct Emoji: Sendable {
        public init(name: String) {
            self.name = name
        }

        public let name: String
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
    public let method: HTTPRequest.Method = .post
    public var path: String {
        let name = emoji.name
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return "/api/v1/statuses/\(statusID)/react/\(name)"
    }
}

