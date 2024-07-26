@testable import Swinub
import XCTest

class WebPushSubscriptionTests: XCTestCase {
    func testDecodeStringID() async throws {
        let json = """
        {
            "id": "your_id_here",
            "endpoint": "your_endpoint_here",
            "alerts": null,
            "serverKey": "your_server_key_here"
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        _ = try decoder.decode(WebPushSubscription.self, from: data)
    }
    
    func testDecodeIntID() async throws {
        let json = """
        {
            "id": 999,
            "endpoint": "your_endpoint_here",
            "alerts": null,
            "serverKey": "your_server_key_here"
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        _ = try decoder.decode(WebPushSubscription.self, from: data)
    }
    
    func testEncodeStringID() async throws {
        let subscription = WebPushSubscription(
            id: .string("id"),
            endpoint: "",
            alerts: nil,
            serverKey: ""
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(subscription)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertEqual(json, #"{"endpoint":"","id":"id","server_key":""}"#)
    }
    
    func testEncodeIntID() async throws {
        let subscription = WebPushSubscription(
            id: .int(100),
            endpoint: "",
            alerts: nil,
            serverKey: ""
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(subscription)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertEqual(json, #"{"endpoint":"","id":100,"server_key":""}"#)
    }
    
    func testDecode() async throws {
        let json = """
        {
          "id": 6452081,
          "endpoint": "https://example.com",
          "alerts": {
            "mention": false,
            "reblog": false,
            "follow": false,
            "favourite": false,
            "poll": false
          },
          "server_key": "xxx",
          "policy": "all"
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let subscription = try decoder.decode(WebPushSubscription.self, from: Data(json.utf8))
        print(subscription)
        //XCTAssertNotNil(subscription.alerts?.follow)
    }
    
    func xtestResponse() async throws {
        let authorization = Authorization(
            host: "mstdn.jp",
            accountID: Account.ID(rawValue: ""),
            oauthToken: ""
        )
        let request = GetV1PushSubscription(authorization: authorization)
        let response = try await SwinubDefaults.session.response(for: request)
        print(response.response)
    }
    
    func xtestResponse2() async throws {
        let authorization = Authorization(
            host: "mstdn.jp",
            accountID: Account.ID(rawValue: ""),
            oauthToken: ""
        )
        var request = PutV1PushSubscription(authorization: authorization)
        request.configuration = .init(
            policy: .all,
            alerts: .init(mention: true, reblog: true, follow: true, favourite: true, poll: true, emojiReaction: false)
        )
        let response = try await SwinubDefaults.session.response(for: request)
        print(response.response)
    }
}
