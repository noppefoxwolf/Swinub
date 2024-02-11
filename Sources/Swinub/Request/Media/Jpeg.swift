import Foundation

// TODO: transformableにする
public struct Jpeg: RequestParameterValue, UploadMedia, Sendable {
    public init(data: Data, name: String) {
        self.data = data
        self.name = name
    }

    let data: Data
    let name: String

    public var parameterValue: String { fatalError() }
    public var multipartValue: Data { data }
    public var multipartFilename: String? { "\(name).jpg" }
    public var multipartContentType: String? { "image/jpg" }
}
