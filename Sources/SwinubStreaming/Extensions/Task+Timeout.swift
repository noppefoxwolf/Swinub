import Foundation

extension Task where Failure == Error {
    
    // Start a new Task with a timeout. If the timeout expires before the operation is
    // completed then the task is cancelled and an error is thrown.
    init(
        priority: TaskPriority? = nil,
        timeout: Duration,
        operation: @escaping @Sendable () async throws -> Success
    ) {
        self = Task(priority: priority) {
            try await withThrowingTaskGroup(of: Success.self) { group -> Success in
                group.addTask(operation: operation)
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
}

private struct TimeoutError: LocalizedError {
    var errorDescription: String? = "Task timed out before completion"
}
