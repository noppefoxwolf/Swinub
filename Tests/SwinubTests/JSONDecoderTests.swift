import Foundation
import Swinub
import Testing

@Suite
struct JSONDecoderTests {
    @Test func uRLDecode() async throws {
        if #available(iOS 17.0, *) {
            // URL(string:) always returns non-nil.
        } else {
            struct Object: Codable {
                let url: URL?
            }
            let urlString = "https://example.com/😀"
            let json = """
                {
                    "url" : "\(urlString)"
                }
                """
            let url = URL(string: urlString)
            #expect(url == nil)
            let object = try JSONDecoder().decode(Object.self, from: Data(json.utf8))
            #expect(object.url == nil)
        }
    }

    @Test func emojiReactionDecode() async throws {
        let json = """
            {
                    "emojiReaction": [
                        {
                            "illigalKey" : "!!!"
                        },
                        {
                            "name" : "name",
                            "count" : 0,
                            "accountIds" : ["id"],
                            "me" : true,
                        }
                    ]
            }
            """
        struct Object: Codable {
            let emojiReaction: [EmojiReaction]?
        }
        let object = try JSONDecoder().decode(Object.self, from: Data(json.utf8))
        #expect(object.emojiReaction?.count == nil)
    }
}
