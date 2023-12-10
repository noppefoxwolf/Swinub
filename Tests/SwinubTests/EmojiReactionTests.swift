import XCTest

class EmojiReactionTests: XCTestCase {
    func testEmojiEncode() {
        let emoji = "😆"
        XCTAssertEqual(
            emoji.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,
            "%F0%9F%98%86"
        )
        let a = "a"
        XCTAssertEqual(a.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!, "a")
        let shortcode = "nightfox_dawn"
        XCTAssertEqual(
            shortcode.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,
            "nightfox_dawn"
        )
        let domain = "nightfox_dawn@fedibird.com"
        XCTAssertEqual(
            domain.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,
            "nightfox_dawn@fedibird.com"
        )
    }
}
