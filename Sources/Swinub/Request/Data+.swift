import Foundation

extension Data {
    static func multipart(
        boundary: String,
        key: String,
        filename: String?,
        contentType: String?,
        value: Data
    ) -> Data {
        var data = Data()
        data.append(Data("\r\n--\(boundary)\r\n".utf8))
        data.append(Data("Content-Disposition: form-data; name=\"\(key)\"".utf8))
        if let filename {
            data.append(Data("; filename=\"\(filename)\"\r\n".utf8))
        } else {
            data.append(Data("\r\n".utf8))
        }
        if let contentType {
            data.append(Data("Content-Type: \(contentType)\r\n".utf8))
        }
        data.append(Data("\r\n".utf8))
        data.append(value)
        return data
    }

    static func multipartEnd(boundary: String) -> Data {
        Data("\r\n--\(boundary)--\r\n".utf8)
    }
}
