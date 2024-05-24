import Foundation
import os

final class WebSocketDelegateHandler: NSObject, URLSessionWebSocketDelegate {
    let logger = Logger(
        subsystem: "dev.noppe.swinub.logger",
        category: #file
    )
    
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        logger.debug("\(#function)")
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        logger.warning("\(#function) \(closeCode.description)")
    }
}
