@testable import Swinub
import Foundation
import HTTPTypes
import Testing

@Suite
struct ScheduledStatusesTests {
    private var authorization: Authorization {
        Authorization(
            host: "example.com",
            accountID: .init(rawValue: "account-1"),
            oauthToken: "token"
        )
    }

    @Test
    func decodeScheduledStatus() throws {
        let json = """
        {
          "id": "3221",
          "scheduled_at": "2019-12-05T12:33:01.000Z",
          "params": {
            "text": "test post",
            "media_ids": ["123", "456"],
            "sensitive": true,
            "spoiler_text": "CW",
            "visibility": "unlisted",
            "language": "ja",
            "scheduled_at": null,
            "poll": {
              "options": ["Yes", "No"],
              "expires_in": "86400",
              "multiple": false,
              "hide_totals": true
            },
            "idempotency": "idem-1",
            "with_rate_limit": false,
            "in_reply_to_id": "999",
            "application_id": 42,
            "quoted_status_id": "888",
            "quote_approval_policy": "followers"
          },
          "media_attachments": []
        }
        """

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsISO8601

        let status = try decoder.decode(ScheduledStatus.self, from: Data(json.utf8))
        #expect(status.id == .init(rawValue: "3221"))
        #expect(status.params.text == "test post")
        #expect(status.params.mediaIds == [.init(rawValue: "123"), .init(rawValue: "456")])
        #expect(status.params.sensitive == true)
        #expect(status.params.spoilerText == "CW")
        #expect(status.params.visibility == .unlisted)
        #expect(status.params.language == "ja")
        #expect(status.params.scheduledAt == nil)
        #expect(status.params.poll == .init(options: ["Yes", "No"], expiresIn: 86_400, multiple: false, hideTotals: true))
        #expect(status.params.idempotency == "idem-1")
        #expect(status.params.withRateLimit == false)
        #expect(status.params.inReplyToId == .init(rawValue: "999"))
        #expect(status.params.applicationId == 42)
        #expect(status.params.quotedStatusId == .init(rawValue: "888"))
        #expect(status.params.quoteApprovalPolicy == .followers)
        #expect(status.mediaAttachments.isEmpty)
    }

    @Test
    func getScheduledStatusesRequest() {
        let endpoint = GetV1ScheduledStatuses(
            authorization: authorization,
            maxID: .init(rawValue: "100"),
            sinceID: .init(rawValue: "10"),
            minID: .init(rawValue: "20"),
            limit: 40
        )

        #expect(endpoint.method == .get)
        #expect(endpoint.path == "/api/v1/scheduled_statuses")
        #expect(endpoint.queryItems == [
            URLQueryItem(name: "max_id", value: "100"),
            URLQueryItem(name: "since_id", value: "10"),
            URLQueryItem(name: "min_id", value: "20"),
            URLQueryItem(name: "limit", value: "40"),
        ])
    }

    @Test
    func getScheduledStatusRequest() {
        let endpoint = GetV1ScheduledStatus(
            id: .init(rawValue: "3221"),
            authorization: authorization
        )

        #expect(endpoint.method == .get)
        #expect(endpoint.path == "/api/v1/scheduled_statuses/3221")
    }

    @Test
    func putScheduledStatusRequest() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = try #require(formatter.date(from: "2026-12-01T12:00:00.000Z"))

        let endpoint = PutV1ScheduledStatus(
            id: .init(rawValue: "3221"),
            scheduledAt: date,
            authorization: authorization
        )

        #expect(endpoint.method == .put)
        #expect(endpoint.path == "/api/v1/scheduled_statuses/3221")

        let body = try #require(endpoint.body)
        switch body {
        case .json(let jsonBody):
            let dictionary = try #require(jsonBody as? [String: Any])
            #expect(dictionary["scheduled_at"] as? String == "2026-12-01T12:00:00.000Z")
        case .multipart:
            #expect(Bool(false))
        }
    }

    @Test
    func postScheduledStatusRequest() throws {
        var parameters = PostV1Statuses.Parameters()
        parameters.status = "scheduled hello"
        parameters.visibility = .unlisted
        parameters.spoilerText = "CW"
        parameters.sensitive = true

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = try #require(formatter.date(from: "2026-12-01T12:00:00.000Z"))

        let endpoint = PostV1ScheduledStatus(
            parameters: parameters,
            scheduledAt: date,
            authorization: authorization
        )

        #expect(endpoint.method == .post)
        #expect(endpoint.path == "/api/v1/statuses")

        let body = try #require(endpoint.body)
        switch body {
        case .json(let jsonBody):
            let dictionary = try #require(jsonBody as? [String: Any])
            #expect(dictionary["status"] as? String == "scheduled hello")
            #expect(dictionary["visibility"] as? String == "unlisted")
            #expect(dictionary["spoiler_text"] as? String == "CW")
            #expect(dictionary["sensitive"] as? Bool == true)
            #expect(dictionary["scheduled_at"] as? String == "2026-12-01T12:00:00.000Z")
        case .multipart:
            #expect(Bool(false))
        }
    }

    @Test
    func deleteScheduledStatusRequest() throws {
        let endpoint = DeleteV1ScheduledStatus(
            id: .init(rawValue: "3221"),
            authorization: authorization
        )

        #expect(endpoint.method == .delete)
        #expect(endpoint.path == "/api/v1/scheduled_statuses/3221")

        _ = try endpoint.decode(Data("{}".utf8))
    }
}
