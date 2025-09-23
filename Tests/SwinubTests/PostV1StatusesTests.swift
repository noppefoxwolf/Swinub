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
}
