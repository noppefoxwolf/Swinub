import Foundation
import os

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

final class SessionWebSocketHandler: NSObject, URLSessionWebSocketDelegate {
    var onOpen: @Sendable () -> Void = {}
    var onClose: @Sendable (_ closeCode: URLSessionWebSocketTask.CloseCode) -> Void = { _ in }
    
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        let host = webSocketTask.currentRequest?.url?.host() ?? "unknown"
        logger.info("OPEN \(host)")
        onOpen()
    }

    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        logger.warning("CLOSE \(closeCode.description)")
        onClose(closeCode)
    }
}
