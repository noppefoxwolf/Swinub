import Foundation

struct MultipartBuilder {
    let boundary: String
    
    init(boundary: String = "__boundary__") {
        self.boundary = boundary
    }
    
    func build(parameters: [String: (any RequestParameterValue)?]) throws -> Data {
        var data = Data()
        
        for parameter in parameters.compactMapValues({ $0 }) {
            try data.append(
                .multipart(
                    boundary: boundary,
                    key: parameter.key,
                    value: parameter.value
                )
            )
        }
        
        data.append(Data.multipartEnd(boundary: boundary))
        return data
    }
    
    var contentType: String {
        #"multipart/form-data; charset=utf-8; boundary="\#(boundary)""#
    }
    
    func isMultipartRequired(parameters: [String: (any RequestParameterValue)?]) -> Bool {
        !parameters.compactMapValues({ $0?.multipartContentType }).isEmpty
    }
}