import Foundation
import Swinub

public protocol StreamingSession: Sendable {
    func webSocketTask<T: StreamingEndpointRequest>(
        for request: T
    ) throws -> WebSocketTask<T.Response>
}

extension URLSession: StreamingSession {
    public func webSocketTask<T: StreamingEndpointRequest>(for request: T) throws -> WebSocketTask<
        T.Response
    > {
        let urlRequest = try request.makeURLRequest()
        let webSocketTask = webSocketTask(with: urlRequest)
        return WebSocketTask(webSocketTask, request: request)
    }
}
