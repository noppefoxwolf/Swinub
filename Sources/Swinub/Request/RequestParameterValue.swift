import Foundation

public protocol UploadMedia {
    var parameterValue: String { get }
    var multipartValue: Data { get }
    var multipartFilename: String? { get }
    var multipartContentType: String? { get }
}

public protocol RequestParameterValue {
    var parameterValue: String { get throws }
    var multipartValue: Data { get throws }
    var multipartContentType: String? { get }
    var multipartFilename: String? { get }
}

public extension RequestParameterValue {
    var multipartValue: Data { get throws { try Data(parameterValue.utf8) } }
    var multipartContentType: String? { nil }
    var multipartFilename: String? { nil }
}

extension Int: RequestParameterValue {
    public var parameterValue: String { "\(self)" }
}
extension String: RequestParameterValue {
    public var parameterValue: String { self }
}
extension Bool: RequestParameterValue {
    public var parameterValue: String { "\(self)" }
}
extension [any RequestParameterValue]: RequestParameterValue {
    public var parameterValue: String {
        get throws {
            try map({ try $0.parameterValue }).joined(separator: ",")
        }
    }
}

extension [String: Any]: RequestParameterValue {
    public var parameterValue: String {
        get throws {
            let jsonData = try JSONSerialization.data(withJSONObject: self)
            let value = String(data: jsonData, encoding: .utf8)
            guard let value else {
                throw GeneralError(errorDescription: "Can not convert jsonData.")
            }
            return value
        }
    }
}
