import Foundation

extension URLSessionWebSocketTask {
    func sendPing(timeout: Duration) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group -> Void in
            group.addTask {
                try await withCheckedThrowingContinuation { continuation in
                    self.sendPing { error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                    }
                }
            }
            group.addTask {
                try await _Concurrency.Task.sleep(for: timeout)
                throw TimeoutError()
                
            }
            guard let success = try await group.next() else {
                throw _Concurrency.CancellationError()
            }
            group.cancelAll()
            return success
        }
    }
}

struct TimeoutError: Error {}
