import Foundation
import CoreTransferable
import CoreTransferableBackport

struct MultipartBuilder {
    let boundary: String
    
    init(boundary: String = "__boundary__") {
        self.boundary = boundary
    }
    
    func build(_ parameters: [(key: String, value: any Transferable & Sendable)]) async throws -> Data {
        var data = Data()
        
        for parameter in parameters {
            let key = parameter.0
            let a = try await multipartBoundaryData(key: key, parameter.1)
        }
        
//        for parameter in parameters.compactMapValues({ $0 }) {
//            data.append(
//                .multipart(
//                    boundary: boundary,
//                    key: parameter.key,
//                    filename: parameter.value.multipartFilename,
//                    contentType: parameter.value.multipartContentType,
//                    value: try parameter.value.multipartValue
//                )
//            )
//        }
        
        data.append(Data.multipartEnd(boundary: boundary))
        return data
    }
    
    func multipartBoundaryData<T: Transferable>(key: String, _ transferable: T) async throws -> Data {
        let filename = transferable.compatible.suggestedFilename
        let contentType = transferable.compatible.exportedContentTypes().first
        let data = try await transferable.compatible.exported(as: .mp3)
        return Data.multipart(boundary: boundary, key: key, filename: filename, contentType: contentType?.identifier, value: data)
    }
    
    var contentType: String {
        #"multipart/form-data; charset=utf-8; boundary="\#(boundary)""#
    }
    
    func isMultipartRequired(parameters: [String: (any RequestParameterValue)?]) -> Bool {
        !parameters.compactMapValues({ $0?.multipartContentType }).isEmpty
    }
}
