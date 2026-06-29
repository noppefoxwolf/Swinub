@testable import Swinub
import Testing
import Foundation

@Suite
struct PostV1StatusesTests {
    @Test
    func parameters() throws {
        let parameters = PostV1Statuses.Parameters()
        let authorization = Authorization(host: "", accountID: .init(rawValue: ""), oauthToken: "")
        let endpoint = PostV1Statuses(parameters: parameters, authorization: authorization)
        let body = endpoint.body
        switch body {
        case .json(let jsonBody):
            let jsonData = try JSONSerialization.data(withJSONObject: jsonBody)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            #expect(!jsonString.contains("media_ids"))
        case .multipart:
            #expect(Bool(false))
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func fedibirdQuoteParameter() throws {
        var parameters = PostV1Statuses.Parameters()
        parameters.quote = .fedibird(.init(rawValue: "fedibird-quote"))
        let authorization = Authorization(host: "", accountID: .init(rawValue: ""), oauthToken: "")
        let endpoint = PostV1Statuses(parameters: parameters, authorization: authorization)
        let body = endpoint.body
        switch body {
        case .json(let jsonBody):
            let dictionary = try #require(jsonBody as? [String: Any])
            #expect(dictionary["quote_id"] as? String == "fedibird-quote")
            #expect(dictionary["quoted_status_id"] == nil)
        case .multipart:
            #expect(Bool(false))
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func mastodonQuoteParameter() throws {
        var parameters = PostV1Statuses.Parameters()
        parameters.quote = .mastodon(.init(rawValue: "mastodon-quote"))
        let authorization = Authorization(host: "", accountID: .init(rawValue: ""), oauthToken: "")
        let endpoint = PostV1Statuses(parameters: parameters, authorization: authorization)
        let body = endpoint.body
        switch body {
        case .json(let jsonBody):
            let dictionary = try #require(jsonBody as? [String: Any])
            #expect(dictionary["quote_id"] == nil)
            #expect(dictionary["quoted_status_id"] as? String == "mastodon-quote")
        case .multipart:
            #expect(Bool(false))
        default:
            #expect(Bool(false))
        }
    }
}
