import AsyncAlgorithms
import Combine
import Foundation
import Network
import os

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

    var retryCount: Int = 0

    public let message: PassthroughSubject<URLSessionWebSocketTask.Message, Never> = .init()

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
        let urlSession = URLSession(configuration: .ephemeral)
        urlSession.configuration.waitsForConnectivity = true
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
                    logger.warning("ERROR \(error.localizedDescription)")
                    await self?.retry()
                } catch {
                    logger.warning("ERROR \(error)")
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

    func retry() async {
        logger.info("RETRY \(self.retryCount)")
        try? await Task.sleep(for: .seconds(retryCount))
        disconnect()
        guard retryCount > 15 else {
            logger.warning("TOO MANY RETRY")
            return
        }
        connect()
        retryCount += 1
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
    }
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

extension URLSessionWebSocketTask.CloseCode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalid:
            return "invalid"
        case .normalClosure:
            return "normalClosure"
        case .goingAway:
            return "goingAway"
        case .protocolError:
            return "protocolError"
        case .unsupportedData:
            return "unsupportedData"
        case .noStatusReceived:
            return "noStatusReceived"
        case .abnormalClosure:
            return "abnormalClosure"
        case .invalidFramePayloadData:
            return "invalidFramePayloadData"
        case .policyViolation:
            return "policyViolation"
        case .messageTooBig:
            return "messageTooBig"
        case .mandatoryExtensionMissing:
            return "mandatoryExtensionMissing"
        case .internalServerError:
            return "internalServerError"
        case .tlsHandshakeFailure:
            return "tlsHandshakeFailure"
        @unknown default:
            return "Default"
        }
    }
}

extension URLSessionWebSocketTask {
    func messages() -> AsyncThrowingStream<URLSessionWebSocketTask.Message, any Error> {
        AsyncThrowingStream<URLSessionWebSocketTask.Message, any Error> {
            try await self.receive()
        }
    }
}
