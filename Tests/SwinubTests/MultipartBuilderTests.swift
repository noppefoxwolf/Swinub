import CoreTransferable
import CoreTransferableBackport
import Foundation
import Testing

@testable import Swinub

@Suite
struct MultipartBuilderTests {
    @Test
    @available(macOS 15.2, *)
    func stringExport() async throws {
        let value1 = "text"
        #expect(value1.backport.exportedContentTypes() == [.utf8PlainText])
        #expect(value1.backport.suggestedFilename == nil)
        try await #expect(value1.backport.exported(as: .utf8PlainText) == Data("text".utf8))
    }

    @Test
    @available(macOS 15.2, *)
    func extract() async throws {
        let jpeg = Jpeg(data: Data("test".utf8), name: "test.jpg")
        let filename = jpeg.compatible.suggestedFilename
        let contentType = jpeg.compatible.exportedContentTypes().first
        let data = try await jpeg.compatible.exported(as: contentType ?? .utf8PlainText)
        #expect(filename == "file.jpg")
        #expect(contentType == .jpeg)
        #expect(data.count == 4)
    }
}

struct Jpeg: Transferable, Sendable {
    let data: Data
    let name: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .jpeg) { $0.data }
            .suggestedFileName("file.jpg")
    }
}
