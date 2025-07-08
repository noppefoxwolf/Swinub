import Foundation

public protocol RequestParameterValue {
    var parameterValue: String { get throws }
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
