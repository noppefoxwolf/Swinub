import Foundation
import Testing

@testable import Swinub

struct NotificationTests {
    private let authorization = Authorization(
        host: "example.com",
        accountID: .init(rawValue: "1"),
        oauthToken: "test"
    )

    @Test func notificationQueryEncodesEachTypeAsAnArrayElement() {
        var request = GetV1Notifications(authorization: authorization)
        request.types = ["mention", "follow"]
        request.supportedTypes = ["quote", "emoji_reaction"]

        #expect(request.queryItems.filter { $0.name == "types[]" }.map(\.value) == ["mention", "follow"])
        #expect(request.queryItems.filter { $0.name == "supported_types[]" }.map(\.value) == ["quote", "emoji_reaction"])

        request.types = []
        #expect(!request.queryItems.contains { $0.name == "types[]" })

        var detail = GetV1NotificationsByID(notificationID: .init(rawValue: "1"), authorization: authorization)
        #expect(detail.queryItems.isEmpty)
        detail.supportedTypes = []
        #expect(detail.queryItems == [URLQueryItem(name: "supported_types[]", value: "")])
    }

    @Test func decodesNotificationDetailsAndUnknownTypes() throws {
        let request = GetV1Notifications(authorization: authorization)
        let account: [String: Any] = [
            "id": "1", "username": "alice", "acct": "alice", "display_name": "Alice",
            "note": "", "fields": [], "emojis": [], "created_at": "2026-01-01T00:00:00.000Z",
            "statuses_count": 0, "followers_count": 0, "following_count": 0, "locked": false,
        ]
        let date = "2026-01-01T00:00:00.000Z"
        let payloads: [(String, [String: Any])] = [
            ("admin.report", ["report": ["id": "2", "action_taken": false, "status_ids": ["27"]]]),
            ("severed_relationships", ["event": [
                "id": "3", "type": "domain_block", "purged": false, "target_name": "example.org",
                "followers_count": 2, "following_count": 3, "created_at": date,
            ]]),
            ("moderation_warning", ["moderation_warning": [
                "id": "4", "action": "none", "text": "", "created_at": date,
                "appeal": ["text": "Please review", "state": "pending"],
            ]]),
            ("added_to_collection", [
                "group_key": "ungrouped-5", "filtered": true,
                "fallback": ["title": "Added to a collection", "description": NSNull()],
                "collection": [
                    "id": "5", "uri": "https://example.com/collections/5", "name": "Artists",
                    "account_id": "1", "local": true, "sensitive": false, "discoverable": true,
                    "item_count": 1, "created_at": date, "updated_at": date,
                    "items": [["id": "6", "state": "accepted", "created_at": date, "account_id": "1"]],
                ],
            ]),
            ("emoji_reaction", [:]),
        ]
        let notifications = try request.decode(JSONSerialization.data(withJSONObject: payloads.map { type, details in
            let common: [String: Any] = ["id": type, "type": type, "account": account, "created_at": date]
            return common.merging(details) { _, detail in detail }
        }))

        #expect(notifications.map(\.type) == payloads.map(\.0))
        #expect(notifications[0].report?.statusIds?.first?.rawValue == "27")
        #expect(notifications[1].event?.targetName == "example.org")
        #expect(notifications[2].moderationWarning?.appeal?.state == "pending")
        #expect(notifications[3].collection?.items.first?.accountId?.rawValue == "1")
        #expect(notifications[3].fallback?.title == "Added to a collection")
        #expect(notifications[3].groupKey == "ungrouped-5")
        #expect(notifications[3].filtered == true)
        #expect(notifications[4].fallback == nil)
    }

    @Test func pushAlertsUseMastodonKeysForCreateUpdateAndResponse() throws {
        var post = PostV1PushSubscription(
            token: Data(),
            endpoint: try #require(URL(string: "https://example.com/push")),
            p256dh: Data(),
            authKey: Data(),
            authorization: authorization,
            urlBuilder: { $0 }
        )
        post.mention = true
        post.alerts.adminSignUp = true
        post.alerts.adminReport = false
        post.alerts.quotedUpdate = true
        post.alerts.addedToCollection = true

        var put = PutV1PushSubscription(authorization: authorization)
        put.configuration.alerts = post.alerts

        for body in [post.body, put.body] {
            guard case .json(let value) = body else {
                Issue.record("Expected a JSON body")
                continue
            }
            let object = try #require(value as? [String: Any])
            let data = try #require(object["data"] as? [String: Any])
            let alerts = try #require(data["alerts"] as? [String: Bool])
            #expect(alerts["mention"] == true)
            #expect(alerts["admin.sign_up"] == true)
            #expect(alerts["admin.report"] == false)
            #expect(alerts["quoted_update"] == true)
            #expect(alerts["added_to_collection"] == true)
            #expect(alerts["collection_update"] == nil)

            let response = try put.decode(JSONSerialization.data(withJSONObject: [
                "id": 1, "endpoint": "https://example.com/push", "server_key": "test", "alerts": alerts,
            ]))
            #expect(response.alerts?.adminSignUp == true)
            #expect(response.alerts?.adminReport == false)
            #expect(response.alerts?.quotedUpdate == true)
            #expect(response.alerts?.addedToCollection == true)
        }
    }
}
