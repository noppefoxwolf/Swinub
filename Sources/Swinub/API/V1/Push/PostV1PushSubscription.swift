import Foundation
import HTTPTypes

public struct PostV1PushSubscription: HTTPEndpointRequest, Sendable {
    public typealias Response = WebPushSubscription

    public init(
        token: Data,
        endpoint: URL,
        p256dh: Data,
        authKey: Data,
        authorization: Authorization,
        urlBuilder: (URL) -> URL // { $0.appending(path: extra) } 
    ) {
        self.authorization = authorization

        let hexToken = token.map { String(format: "%02x", $0) }.joined()
        self.endpoint = urlBuilder(endpoint.appending(path: hexToken))
        self.p256dh = p256dh
        self.authKey = authKey
    }
    public var authorization: Authorization
    let endpoint: URL
    let p256dh: Data
    let authKey: Data

    public var mention: Bool = false
    public var reblog: Bool = false
    public var follow: Bool = false
    public var favourite: Bool = false
    public var poll: Bool = false
    public var emojiReaction: Bool = false
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/push/subscription" }
    public var body: EndpointRequestBody? {
        .json([
            "subscription": [
                "endpoint": endpoint.absoluteString,
                "keys": [
                    "p256dh": p256dh.base64UrlEncodedString(),
                    "auth": authKey.base64UrlEncodedString(),
                ],
            ],
            "data": [
                "policy": "all",
                "alerts": [
                    "mention": mention,
                    "reblog": reblog,
                    "follow": follow,
                    "favourite": favourite,
                    "poll": poll,
                    "emoji_reaction": emojiReaction,
                ],
            ],
        ])
    }
}

extension Data {
    fileprivate func base64UrlEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

public struct SubscriptionConfiguration: Sendable {
    public enum Policy: String, Sendable {
        case all
        case followed
        case follower
        case none
    }

    public struct Alerts: Sendable {
        public var mention: Bool = false
        public var reblog: Bool = false
        public var follow: Bool = false
        public var favourite: Bool = false
        public var poll: Bool = false
        public var emojiReaction: Bool = false
    }

    public var policy: Policy = .all
    public var alerts: Alerts = .init()
}
