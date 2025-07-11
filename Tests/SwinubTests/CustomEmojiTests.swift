import Foundation
import Swinub
import Testing

@Suite
struct CustomEmojiTests {
    @Test func fedibirdJSON() async throws {
        // aliasesが無い場合でも[String]にはマッピングされないので、[String]?で持つ
        let json = """
            {
              "shortcode": "shortcode",
              "visible_in_picker": true
            }
            """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        _ = try decoder.decode(Swinub.CustomEmoji.self, from: data)
    }
}
