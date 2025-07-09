import Foundation
import RegexBuilder
import Testing

@testable import Swinub

@Suite
struct HeaderLinkDecoderTests {
    @Test func decode() async throws {
        let linkHeader =
            #"<https://mastodon.social/api/v1/timelines/home?limit=20&max_id=111109132778344003>; rel="next", <https://mastodon.social/api/v1/timelines/home?limit=20&min_id=111125014356913351>; rel="prev""#
        let cursors = ResponseHeaderLinkDecoder().decode(from: Data(linkHeader.utf8))
        #expect(cursors.0 == PrevCursor(minID: "111125014356913351"))
        #expect(cursors.1 == NextCursor(maxID: "111109132778344003"))
    }

    @Test func decodeInvalidRelation() async throws {
        let linkHeader =
            #"<https://mastodon.social/api/v1/timelines/home?limit=20&max_id=111109132778344003>; rel="invalid""#
        let cursors = ResponseHeaderLinkDecoder().decode(from: Data(linkHeader.utf8))
        #expect(cursors.0 == nil)
        #expect(cursors.1 == nil)
    }

    @Test func blankData() async throws {
        let linkHeader = ""
        let cursors = ResponseHeaderLinkDecoder().decode(from: Data(linkHeader.utf8))
        #expect(cursors.0 == nil)
    }
}
