import Foundation

extension URLSessionWebSocketTask.Message {
    func string() -> String? {
        guard case .string(let string) = self else { return nil }
        return string
    }
}
