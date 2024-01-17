import Foundation

extension URLSessionTask.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .running:
            return "Running"
        case .suspended:
            return "Suspended"
        case .canceling:
            return "Canceling"
        case .completed:
            return "Completed"
        @unknown default:
            return "Default"
        }
    }
}

