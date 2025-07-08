import Foundation
import CoreTransferable
import CoreTransferableBackport

struct MultipartBuilder {
    let boundary: String
    
    init(boundary: String = "__boundary__") {
        self.boundary = boundary
    }
    
    func build(_ items: [MultipartFormItem]) async throws -> Data {
        var data = Data()
        
        for item in items {
            if let value = item.value {
                let partData = try await multipartBoundaryData(
                    key: item.name,
                    value
                )
                data.append(partData)
            }
        }
        
        data.append(Data.multipartEnd(boundary: boundary))
        return data
    }
    
    func multipartBoundaryData<T: Transferable & Sendable>(key: String, _ transferable: T) async throws -> Data {
        let filename = transferable.compatible.suggestedFilename
        let contentType = transferable.compatible.exportedContentTypes().first
        let data = try await transferable.compatible.exported(as: contentType ?? .utf8PlainText)
        return Data.multipart(boundary: boundary, key: key, filename: filename, contentType: contentType?.identifier, value: data)
    }
    
    var contentType: String {
        #"multipart/form-data; charset=utf-8; boundary="\#(boundary)""#
    }
}
