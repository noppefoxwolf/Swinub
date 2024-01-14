import Swinub
import XCTest

class PreferenceTests: XCTestCase {
    func testNilKey() async throws {
        let json = """
            {
                
            }
            """
        let object = try JSONDecoder().decode(Preference.self, from: Data(json.utf8))
        XCTAssertNil(object.postingDefaultVisibility)
    }

    func testKey() async throws {
        let json = """
            {
                "posting:default:visibility" : "Hello",
                "posting:default:sensitive" : false
            }
            """
        let object = try JSONDecoder().decode(Preference.self, from: Data(json.utf8))
        XCTAssertEqual(object.postingDefaultVisibility, .init(rawValue: "Hello"))
    }
}
