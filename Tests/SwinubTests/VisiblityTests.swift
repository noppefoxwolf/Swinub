import XCTest

@testable import Swinub

class StatusVisibilityTests: XCTestCase {
    func testStatusVisibility() async throws {
        let rawValue = "public_unlisted"
        let visibility = StatusVisibility(rawValue: rawValue)
        XCTAssertEqual(visibility, .publicUnlisted)
    }

    func testStatusVisibility2() async throws {
        let rawValue = "publicUnlisted"
        let visibility = StatusVisibility(rawValue: rawValue)
        XCTAssertEqual(visibility, .init(rawValue: "publicUnlisted"))
    }
    
    func testOrder() async throws {
        XCTAssertGreaterThan(StatusVisibility.public, StatusVisibility.private)
    }
    
    func testOrder2() async throws {
        XCTAssertLessThan(StatusVisibility.private, StatusVisibility.public)
    }
}
