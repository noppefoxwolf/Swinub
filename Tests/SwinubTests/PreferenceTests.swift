import Swinub
import Testing
import Foundation

@Suite
struct PreferenceTests {
    @Test func nilKey() async throws {
        let json = """
            {
                
            }
            """
        let object = try JSONDecoder().decode(Preference.self, from: Data(json.utf8))
        #expect(object.postingDefaultVisibility == nil)
    }

    @Test func key() async throws {
        let json = """
            {
                "posting:default:visibility" : "Hello",
                "posting:default:sensitive" : false
            }
            """
        let object = try JSONDecoder().decode(Preference.self, from: Data(json.utf8))
        #expect(object.postingDefaultVisibility == .init(rawValue: "Hello"))
    }
}
