import Foundation
import Swinub
import Testing

@Suite
struct JSONSerializeTests {
    @Test func serialize() throws {
        //        let parameters: [String : String] = [
        //            "v" : "[1,2,3,4]"
        //        ]
        let parameters: [String: Any] = [
            "v": [1, 2, 3, 4]
        ]
        let httpBody = try JSONSerialization.data(
            withJSONObject: parameters,
            options: []
        )
        _ = String(data: httpBody, encoding: .utf8)!

        struct JsonObject: Codable {
            let v: [Int]
        }
        let json2 = try JSONDecoder().decode(JsonObject.self, from: httpBody)
        #expect(json2.v == [1, 2, 3, 4])
    }
}
