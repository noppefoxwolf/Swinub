import Foundation

extension URLSessionWebSocketTask {
    func messages() -> AsyncThrowingStream<URLSessionWebSocketTask.Message, any Error> {
        AsyncThrowingStream<URLSessionWebSocketTask.Message, any Error> {
            try await self.receive()
        }
    }
}
