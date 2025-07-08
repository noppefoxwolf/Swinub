import Testing
import Foundation

@Suite
struct MultipartBuilderTests {
    @Test
    @available(macOS 15.2, *)
    func stringExport() async throws {
        let value1 = "text"
        #expect(value1.exportedContentTypes() == [.utf8PlainText])
        #expect(value1.suggestedFilename == nil)
        try await #expect(value1.exported(as: .utf8PlainText) == Data("text".utf8))
    }
}
