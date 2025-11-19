import Testing

@testable import Swinub

@Suite

struct StatusVisibilityTests {
    @Test func statusVisibility() async throws {
        let rawValue = "public_unlisted"
        let visibility = StatusVisibility(rawValue: rawValue)
        #expect(visibility == .publicUnlisted)
    }

    @Test func statusVisibility2() async throws {
        let rawValue = "publicUnlisted"
        let visibility = StatusVisibility(rawValue: rawValue)
        #expect(visibility == .init(rawValue: "publicUnlisted"))
    }
}
