import Testing
import HTTPTypes
@testable import Swinub
import Foundation

@Suite
struct FollowRequestsTests {
    @Test
    func getFollowRequests() async throws {
        let authorization = Authorization(
            host: "",
            accountID: Account.ID(rawValue: ""),
            oauthToken: ""
        )
        let request = GetV1FollowRequests(authorization: authorization)
        let response = try await SwinubDefaults.session.response(for: request)
        print(response)
    }
}
