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
        urlBuilder: (URL) -> URL  // { $0.appending(path: extra) }
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

    public var alerts: SubscriptionConfiguration.Alerts = .init()

    public var mention: Bool {
        get { alerts.mention }
        set { alerts.mention = newValue }
    }

    public var reblog: Bool {
        get { alerts.reblog }
        set { alerts.reblog = newValue }
    }

    public var follow: Bool {
        get { alerts.follow }
        set { alerts.follow = newValue }
    }

    public var followRequest: Bool {
        get { alerts.followRequest }
        set { alerts.followRequest = newValue }
    }

    public var favourite: Bool {
        get { alerts.favourite }
        set { alerts.favourite = newValue }
    }

    public var poll: Bool {
        get { alerts.poll }
        set { alerts.poll = newValue }
    }

    public var emojiReaction: Bool {
        get { alerts.emojiReaction }
        set { alerts.emojiReaction = newValue }
    }

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
                "alerts": alerts.parameters,
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
        public var followRequest: Bool = false
        public var favourite: Bool = false
        public var poll: Bool = false
        public var emojiReaction: Bool = false
        public var status: Bool?
        public var update: Bool?
        public var quote: Bool?
        public var quotedUpdate: Bool?
        public var severedRelationships: Bool?
        public var moderationWarning: Bool?
        public var annualReport: Bool?
        public var adminSignUp: Bool?
        public var adminReport: Bool?
        public var addedToCollection: Bool?
        public var collectionUpdate: Bool?

        var parameters: [String: Bool] {
            let values: [String: Bool?] = [
                "mention": mention,
                "reblog": reblog,
                "follow": follow,
                "follow_request": followRequest,
                "favourite": favourite,
                "poll": poll,
                "emoji_reaction": emojiReaction,
                "status": status,
                "update": update,
                "quote": quote,
                "quoted_update": quotedUpdate,
                "severed_relationships": severedRelationships,
                "moderation_warning": moderationWarning,
                "annual_report": annualReport,
                "admin.sign_up": adminSignUp,
                "admin.report": adminReport,
                "added_to_collection": addedToCollection,
                "collection_update": collectionUpdate,
            ]
            return values.compactMapValues { $0 }
        }
    }

    public var policy: Policy = .all
    public var alerts: Alerts = .init()
}
