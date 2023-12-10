import Swinub
import XCTest

class JSONDecoderTests: XCTestCase {
    func testURLDecode() async throws {
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
            XCTAssertNil(url)
            let object = try JSONDecoder().decode(Object.self, from: Data(json.utf8))
            XCTAssertNil(object.url)
        }
    }

    func testEmojiReactionDecode() async throws {
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
        XCTAssertEqual(object.emojiReaction?.count, nil)
    }
}
