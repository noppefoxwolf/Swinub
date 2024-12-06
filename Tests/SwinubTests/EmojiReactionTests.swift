import Testing

@Suite 

struct EmojiReactionTests {
    @Test func emojiEncode() {
        let emoji = "😆"
        #expect(
            emoji.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)! == "%F0%9F%98%86"
        )
        let a = "a"
        #expect(a.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)! == "a")
        let shortcode = "nightfox_dawn"
        #expect(
            shortcode.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)! == "nightfox_dawn"
        )
        let domain = "nightfox_dawn@fedibird.com"
        #expect(
            domain.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)! == "nightfox_dawn@fedibird.com"
        )
    }
}
