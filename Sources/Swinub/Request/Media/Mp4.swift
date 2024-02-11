import Foundation

public struct Mp4: RequestParameterValue, UploadMedia, Sendable {
    public init(data: Data, name: String) {
        self.data = data
        self.name = name
    }

    let data: Data
    let name: String

    public var parameterValue: String { fatalError() }
    public var multipartValue: Data { data }
    public var multipartFilename: String? { "\(name).mp4" }
    public var multipartContentType: String? { "video/mp4" }
}
