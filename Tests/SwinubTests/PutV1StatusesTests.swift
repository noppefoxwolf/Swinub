@testable import Swinub
import Foundation
import HTTPTypes
import Testing

@Suite
struct PutV1StatusesTests {
    @Test
    func request() throws {
        var parameters = PutV1Statuses.Parameters()
        parameters.status = "edited"
        parameters.spoilerText = "CW"
        parameters.sensitive = true
        parameters.language = Locale.Language(identifier: "ja")
        parameters.mediaIDs = [.init(rawValue: "media-1")]
        parameters.quoteApprovalPolicy = .followers

        let authorization = Authorization(
            host: "example.com",
            accountID: .init(rawValue: "account-1"),
            oauthToken: "token"
        )
        let endpoint = PutV1Statuses(
            statusID: .init(rawValue: "status-1"),
            parameters: parameters,
            authorization: authorization
        )

        #expect(endpoint.method == .put)
        #expect(endpoint.path == "/api/v1/statuses/status-1")

        let body = try #require(endpoint.body)
        switch body {
        case .json(let jsonBody):
            let dictionary = try #require(jsonBody as? [String: Any])
            #expect(dictionary["status"] as? String == "edited")
            #expect(dictionary["spoiler_text"] as? String == "CW")
            #expect(dictionary["sensitive"] as? Bool == true)
            #expect(dictionary["language"] as? String == "ja")
            #expect(dictionary["media_ids"] as? [String] == ["media-1"])
            #expect(dictionary["quote_approval_policy"] as? String == "followers")
        case .multipart:
            #expect(Bool(false))
        }
    }

    @Test
    func pollParameters() throws {
        var parameters = PutV1Statuses.Parameters()
        parameters.pollOptions = ["Yes", "", "No"]
        parameters.pollExpiresIn = 3_600
        parameters.pollMultiple = true
        parameters.pollHideTotals = true

        let authorization = Authorization(host: "", accountID: .init(rawValue: ""), oauthToken: "")
        let endpoint = PutV1Statuses(
            statusID: .init(rawValue: "status-1"),
            parameters: parameters,
            authorization: authorization
        )

        let body = try #require(endpoint.body)
        switch body {
        case .json(let jsonBody):
            let dictionary = try #require(jsonBody as? [String: Any])
            let poll = try #require(dictionary["poll"] as? [String: Any])
            #expect(poll["options"] as? [String] == ["Yes", "No"])
            #expect(poll["expires_in"] as? Int == 3_600)
            #expect(poll["multiple"] as? Bool == true)
            #expect(poll["hide_totals"] as? Bool == true)
        case .multipart:
            #expect(Bool(false))
        }
    }
}
