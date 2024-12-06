import Swinub
import Testing
import Foundation

@Suite
struct RequestParameterValueTests {
    @Test func requestParameterValue() throws {
        let params: [String: any RequestParameterValue] = [
            "a": 0,
            "b": Optional<Int>.none,
            "c": true,
            "d": Optional<Bool>.none,
            "e": ["a", "b", "c"],
            "f": [
                "fa": "fv",
                "fb": false,
            ],
        ]
        .compactMapValues({ $0 })
        #expect(params.count == 4)
    }

    @Test func queryItem() throws {
        let item = try URLQueryItem(name: "name", value: ["key": "value"].parameterValue)
        print(item.value as Any)
    }
}
