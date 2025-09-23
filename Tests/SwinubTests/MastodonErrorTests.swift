import Swinub
import Testing
import Foundation

@Suite
struct MastodonErrorTests {
    @Test
    func decode() throws {
        let json = #"{"error":"Error description"}"#
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsISO8601
        let error = try decoder.decode(MastodonError.self, from: Data(json.utf8))
        #expect(error.error == "Error description")
    }
}
