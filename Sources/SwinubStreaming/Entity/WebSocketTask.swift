import Foundation
import Swinub

public final class WebSocketTask<Message: Decodable & Sendable>: Sendable {
    public let task: URLSessionWebSocketTask
    public let messages: AsyncThrowingStream<Message, any Error>
    
    init<RequestType: EndpointRequest>(_ task: URLSessionWebSocketTask, request: RequestType) where RequestType.Response == Message {
        self.task = task
        self.messages = AsyncThrowingStream<Message, any Error>(
            unfolding: {
                try Task.checkCancellation()
                let message = try await task.receive()
                guard let string = message.string() else { return nil }
                let data = Data(string.utf8)
                do {
                    return try request.decode(data)
                } catch {
                    // skip decode error
                    #if DEBUG
                    print(error)
                    #endif
                    return nil
                }
            }
        )
    }
    
    public func resume() {
        task.resume()
    }
    
    public func cancel() {
        task.cancel(with: .normalClosure, reason: nil)
    }
}
