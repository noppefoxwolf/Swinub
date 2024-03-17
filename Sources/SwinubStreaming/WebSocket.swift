import AsyncAlgorithms
import Combine
import Foundation
import Network
import os

fileprivate let logger = Logger(
    subsystem: "dev.noppe.swinub.logger",
    category: #file
)

public final class WebSocket: Sendable {
    let url: URL
    let authorization: String
    let userAgent: String

    var webSocketTask: URLSessionWebSocketTask?
    var webSocketDelegateHandler = WebSocketDelegateHandler()
    var webSocketReceiveTask: Task<Void, any Error>?
    var stateObservation: NSKeyValueObservation? = nil
    var errorObservation: NSKeyValueObservation? = nil

    public let messagePublisher: PassthroughSubject<URLSessionWebSocketTask.Message, any Error> = .init()

    public init(url: URL, authorization: String, userAgent: String = "dawn") {
        self.url = url
        self.authorization = authorization
        self.userAgent = userAgent
    }

    deinit {
        disconnect()
    }

    // https://docs.joinmastodon.org/methods/streaming/#websocket
    // https://github.com/shiguredo/sora-ios-sdk/blob/develop/Sora/URLSessionWebSocketChannel.swift
    // https://github.com/cinderella-project/iMast/issues/140
    // https://github.com/h3poteto/megalodon/pull/49/files
    public func connect() {
        logger.debug("\(#function)")
        
        let urlSession = URLSession(configuration: .ephemeral)
        urlSession.configuration.waitsForConnectivity = true
        var request = URLRequest(url: url)
        request.addValue(authorization, forHTTPHeaderField: "Authorization")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        let webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask.delegate = webSocketDelegateHandler
        webSocketTask.resume()
        
        webSocketReceiveTask = Task.detached(
            priority: .background,
            operation: { [weak webSocketTask, weak messagePublisher] in
                guard let webSocketTask else { return }
                do {
                    for try await message in webSocketTask.messages() {
                        messagePublisher?.send(message)
                    }
                } catch let error as NSError {
                    // error    NSURLError    domain: "NSPOSIXErrorDomain" - code: 57    0x0000600000cda730
                    logger.warning("ERROR \(error.localizedDescription)")
                    messagePublisher?.send(completion: .failure(error))
                } catch {
                    logger.warning("ERROR \(error)")
                    messagePublisher?.send(completion: .failure(error))
                }
            }
        )
        
        stateObservation = webSocketTask
            .observe(\.state) { (task, change) in
                logger.info("STATE \(task.state)")
            }
        
        errorObservation = webSocketTask
            .observe(\.error) { (task, change) in
                logger.info("Error \(task.error)")
            }
        
        self.webSocketTask = webSocketTask
    }

    public func disconnect() {
        logger.debug("\(#function)")
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketReceiveTask?.cancel()
        stateObservation?.invalidate()
    }
}
