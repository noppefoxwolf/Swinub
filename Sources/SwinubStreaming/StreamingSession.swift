import Swinub
import Foundation

public protocol StreamingSession: Sendable {
    func webSocketTask<T: Request>(
        for request: T
    ) throws -> WebSocketTask<T.Response>
}

extension URLSession: StreamingSession {
    public func webSocketTask<T: Request>(for request: T) throws -> WebSocketTask<T.Response> {
        var urlRequest = try request.makeURLRequest()
        let webSocketTask = webSocketTask(with: urlRequest)
        return WebSocketTask(webSocketTask, request: request)
    }
}
