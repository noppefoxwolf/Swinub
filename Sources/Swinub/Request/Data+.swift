import Foundation

extension Data {
    static func multipart(
        boundary: String,
        key: String,
        value: any RequestParameterValue
    ) throws -> Data {
        var data = Data()
        data.append(Data("\r\n--\(boundary)\r\n".utf8))
        data.append(Data("Content-Disposition: form-data; name=\"\(key)\"".utf8))
        if let filename = value.multipartFilename {
            data.append(Data("; filename=\"\(filename)\"\r\n".utf8))
        } else {
            data.append(Data("\r\n".utf8))
        }
        if let contentType = value.multipartContentType {
            data.append(Data("Content-Type: \(contentType)\r\n".utf8))
        }
        data.append(Data("\r\n".utf8))
        try data.append(value.multipartValue)
        return data
    }

    static func multipartEnd(boundary: String) -> Data {
        Data("\r\n--\(boundary)--\r\n".utf8)
    }
}
