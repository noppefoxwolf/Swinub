@testable import Swinub
import Foundation
import Testing

@Suite
struct AccountSubscribeTests {
    @Test
    func subscribeRequestBodyOptions() throws {
        var request = PostV1AccountsSubscribe(
            id: .init(rawValue: "42"),
            authorization: Authorization(host: "example.com", accountID: .init(rawValue: "100"), oauthToken: "token")
        )
        #expect(request.body == nil)

        request.reblogs = false
        request.mediaOnly = true
        request.listID = .init(rawValue: "9")

        guard case let .json(payload)? = request.body else {
            Issue.record("Expected JSON payload for subscribe request")
            return
        }

        let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(object?["reblogs"] as? Bool == false)
        #expect(object?["media_only"] as? Bool == true)
        #expect(object?["list_id"] as? String == "9")
    }

    @Test
    func unsubscribeRequestBodyOptions() throws {
        var request = PostV1AccountsUnsubscribe(
            id: .init(rawValue: "42"),
            authorization: Authorization(host: "example.com", accountID: .init(rawValue: "100"), oauthToken: "token")
        )

        #expect(request.body == nil)

        request.listID = .init(rawValue: "7")

        guard case let .json(payload)? = request.body else {
            Issue.record("Expected JSON payload for unsubscribe request")
            return
        }

        let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(object?["list_id"] as? String == "7")
        #expect(object?.keys.count == 1)
    }

    @Test
    func relationshipDecodingIncludesAccountSubscribing() throws {
        let json = """
        {
          "id": "123",
          "following": false,
          "followed_by": true,
          "account_subscribing": {
            "-1": { "reblogs": true },
            "5": { "reblogs": false, "media_only": true }
          },
          "blocking": false,
          "blocked_by": false,
          "muting": false,
          "requested": false
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let relationship = try decoder.decode(Relationship.self, from: data)

        #expect(relationship.followedBy == true)
        guard let subscriptions = relationship.accountSubscribing else {
            Issue.record("Expected accountSubscribing to be populated")
            return
        }
        #expect(subscriptions.count == 2)
        #expect(subscriptions["-1"]?.reblogs == true)
        #expect(subscriptions["-1"]?.mediaOnly == nil)
        #expect(subscriptions["5"]?.reblogs == false)
        #expect(subscriptions["5"]?.mediaOnly == true)
    }
}
