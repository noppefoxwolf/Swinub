import RegexBuilder
import XCTest

@testable import Swinub

class HeaderLinkDecoderTests: XCTestCase {
    func testDecode() async throws {
        let linkHeader =
            #"<https://mastodon.social/api/v1/timelines/home?limit=20&max_id=111109132778344003>; rel="next", <https://mastodon.social/api/v1/timelines/home?limit=20&min_id=111125014356913351>; rel="prev""#
        let cursors = ResponseHeaderLinkDecoder().decode(from: Data(linkHeader.utf8))
        XCTAssertEqual(cursors.0, PrevCursor(minID: "111125014356913351"))
        XCTAssertEqual(cursors.1, NextCursor(maxID: "111109132778344003"))
    }

    func testDecodeInvalidRelation() async throws {
        let linkHeader =
            #"<https://mastodon.social/api/v1/timelines/home?limit=20&max_id=111109132778344003>; rel="invalid""#
        let cursors = ResponseHeaderLinkDecoder().decode(from: Data(linkHeader.utf8))
        XCTAssertNil(cursors.0)
        XCTAssertNil(cursors.1)
    }

    func testBlankData() async throws {
        let linkHeader = ""
        let cursors = ResponseHeaderLinkDecoder().decode(from: Data(linkHeader.utf8))
        XCTAssertNil(cursors.0)
    }
}
