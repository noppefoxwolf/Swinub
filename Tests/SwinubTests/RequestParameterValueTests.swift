import Swinub
import XCTest

class RequestParameterValueTests: XCTestCase {
    func testRequestParameterValue() throws {
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
        XCTAssertEqual(params.count, 4)
    }

    func testQueryItem() throws {
        let item = try URLQueryItem(name: "name", value: ["key": "value"].parameterValue)
        print(item.value as Any)
    }
}
