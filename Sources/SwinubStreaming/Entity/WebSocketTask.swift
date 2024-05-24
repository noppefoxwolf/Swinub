import Foundation
import Swinub

public final class WebSocketTask<RequestType: Request>: Sendable {
    let task: URLSessionWebSocketTask
    let requset: RequestType
    public let messages: AsyncThrowingStream<RequestType.Response, any Error>
    
    init(_ task: URLSessionWebSocketTask, request: RequestType) {
        self.task = task
        self.requset = request
        self.messages = AsyncThrowingStream<RequestType.Response, any Error>(
            unfolding: {
                let message = try await task.receive()
                guard let string = message.string() else { return nil }
                let data = Data(string.utf8)
                return try? request.decode(data)
            }
        )
    }
    
    public func resume() {
        task.resume()
    }
    
    public func cancel() {
        task.cancel()
    }
}
