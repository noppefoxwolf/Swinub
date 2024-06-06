import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/preferences/
public struct PostV1PollsVotes: AuthorizationEndpointRequest, Sendable {
    public typealias Response = Poll

    public init(id: Poll.ID, authorization: Authorization) {
        self.pollID = id
        self.authorization = authorization
    }
    let pollID: Poll.ID
    public var choices: [Int] = []
    public let authorization: Authorization
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/polls/\(pollID)/votes" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "choices": choices as [any RequestParameterValue]
        ]
    }
}
