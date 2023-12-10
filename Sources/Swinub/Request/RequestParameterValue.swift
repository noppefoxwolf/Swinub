import Foundation

public protocol RequestParameterValue {
    var parameterValue: String { get }
    var multipartValue: Data { get }
    var multipartContentType: String? { get }
    var multipartFilename: String? { get }
}

public extension RequestParameterValue {
    var multipartValue: Data { Data(parameterValue.utf8) }
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
    public var parameterValue: String { map(\.parameterValue).joined(separator: ",") }
}

extension [String: Any]: RequestParameterValue {
    public var parameterValue: String {
        let jsonData = try! JSONSerialization.data(withJSONObject: self)
        return String(data: jsonData, encoding: .utf8)!
    }
}
