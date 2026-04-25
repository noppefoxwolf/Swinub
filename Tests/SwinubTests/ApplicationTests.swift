import Foundation
import Testing

@testable import Swinub

@Suite
struct ApplicationTests {
    @Test func decodeWithoutVapidKey() async throws {
        let json = """
            {
                "id": "123",
                "name": "test app",
                "website": null,
                "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
                "client_id": "client-id",
                "client_secret": "client-secret"
            }
            """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let application = try decoder.decode(Application.self, from: data)
        #expect(application.vapidKey == nil)
    }
}
