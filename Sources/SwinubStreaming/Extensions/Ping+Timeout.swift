import Foundation

extension URLSessionWebSocketTask {
    func sendPing(timeout: Duration) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group -> Void in
            group.addTask {
                try await withTaskCancellationHandler {
                    try await withCheckedThrowingContinuation { continuation in
                        self.sendPing { error in
                            if let error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume()
                            }
                        }
                    }
                } onCancel: {
                    self.cancel()
                }
            }
            group.addTask {
                try await Task.sleep(for: timeout)
                throw TimeoutError()
                
            }
            guard let success = try await group.next() else {
                throw CancellationError()
            }
            group.cancelAll()
            return success
        }
    }
}

struct TimeoutError: Error {}
