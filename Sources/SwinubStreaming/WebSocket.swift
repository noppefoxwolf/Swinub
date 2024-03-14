import AsyncAlgorithms
import Combine
import Foundation
import Network
import os
import HTTPTypes

fileprivate let logger = Logger(
    subsystem: "dev.noppe.swinub.logger",
    category: #file
)

public final class WebSocket: NSObject, URLSessionWebSocketDelegate, @unchecked Sendable {
    let url: URL
    let authorization: String
    let userAgent: String

    var webSocketTask: URLSessionWebSocketTask?
    var webSocketReceiveTask: Task<Void, any Error>?
    var pingTask: Task<Void, any Error>?
    var stateObservation: NSKeyValueObservation? = nil

    public let message: PassthroughSubject<URLSessionWebSocketTask.Message, any Error> = .init()

    public init(url: URL, authorization: String, userAgent: String = "dawn") {
        self.url = url
        self.authorization = authorization
        self.userAgent = userAgent
    }

    deinit {
        webSocketReceiveTask?.cancel()
        pingTask?.cancel()
    }

    // https://docs.joinmastodon.org/methods/streaming/#websocket
    // https://github.com/shiguredo/sora-ios-sdk/blob/develop/Sora/URLSessionWebSocketChannel.swift
    // https://github.com/cinderella-project/iMast/issues/140
    // https://github.com/h3poteto/megalodon/pull/49/files
    public func connect() {
        var configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = true
        let urlSession = URLSession(configuration: configuration)
        var request = URLRequest(url: url)
        request.addValue(authorization, forHTTPHeaderField: "Authorization")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        let webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask.delegate = self
        webSocketReceiveTask = Task.detached(
            priority: .background,
            operation: { [weak self] in
                guard let webSocketTask = self?.webSocketTask else { return }
                do {
                    for try await message in webSocketTask.messages() {
                        self?.message.send(message)
                    }
                } catch let error as NSError {
                    // error    NSURLError    domain: "NSPOSIXErrorDomain" - code: 57    0x0000600000cda730
                    logger.warning("ERROR \(error.localizedDescription)")
                    self?.message.send(completion: .failure(error))
                } catch {
                    logger.warning("ERROR \(error)")
                    self?.message.send(completion: .failure(error))
                }
            }
        )

        pingTask = Task.detached(
            priority: .background,
            operation: { [weak self] in
                do {
                    while true {
                        let host = self?.url.host() ?? "unknown host"
                        logger.info("PING \(host)")
                        try await self?.webSocketTask?.sendPing()
                        logger.info("PING OK")
                        // https://stackoverflow.com/a/25235877
                        try await Task.sleep(for: .seconds(20))
                    }
                } catch let error as NSError {
                    
                    logger.warning("PING ERR \(error.localizedDescription)")
                } catch {
                    logger.warning("PING ERR \(error)")
                }
            }
        )
        
        stateObservation = webSocketTask
            .observe(\.state) { (task, change) in
                logger.info("STATE \(task.state)")
            }

        webSocketTask.resume()
        logger.info("CONNECT")
        
        self.webSocketTask = webSocketTask
    }

    public func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)

        pingTask?.cancel()
        webSocketReceiveTask?.cancel()

        stateObservation?.invalidate()

        logger.info("DISCONNECT")
    }

    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        let host = url.host() ?? "unknown"
        logger.info("OPEN \(host)")
    }

    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        logger.warning("CLOSE \(closeCode.description)")
        // https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/closecode
        message.send(completion: .failure(WebSocketError(closeCode: closeCode)))
    }
}

public struct WebSocketError: Error {
    public let closeCode: URLSessionWebSocketTask.CloseCode
}

extension URLSessionWebSocketTask {
    func sendPing() async throws {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            sendPing(pongReceiveHandler: { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            })
        }
    }
}

