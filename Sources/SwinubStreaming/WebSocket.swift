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

public final class WebSocket: Sendable {
    let url: URL
    let authorization: String
    let userAgent: String
    let handler = SessionWebSocketHandler()
    var webSocketTask: URLSessionWebSocketTask?
    var webSocketReceiveTask: Task<Void, any Error>?
    var stateObservation: AnyCancellable? = nil
    var pingTimerCanceller: AnyCancellable? = nil

    public let message: PassthroughSubject<URLSessionWebSocketTask.Message, any Error> = .init()

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
        var configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = true
        let urlSession = URLSession(configuration: configuration)
        var request = URLRequest(url: url)
        request.networkServiceType = .responsiveData
        request.timeoutInterval = 10
        request.addValue(authorization, forHTTPHeaderField: "Authorization")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask.delegate = handler
        
        startReceiveMessages()
        startPing()

        stateObservation = webSocketTask
            .publisher(for: \.state)
            .removeDuplicates()
            .sink(receiveValue: { state in
                logger.info("STATE \(state)")
            })
        
        handler.onOpen = {}
        handler.onClose = { [weak message] closeCode in
            // https://developer.apple.com/documentation/foundation/urlsessionwebsockettask/closecode
            message?.send(completion: .failure(WebSocketCloseError(closeCode: closeCode)))
        }

        webSocketTask.resume()
        logger.info("CONNECT")
        
        self.webSocketTask = webSocketTask
    }

    public func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)

        pingTimerCanceller?.cancel()
        webSocketReceiveTask?.cancel()

        stateObservation?.cancel()

        logger.info("DISCONNECT")
    }
    
    func startReceiveMessages() {
        webSocketReceiveTask = Task.detached(
            priority: .background,
            operation: { [weak webSocketTask, weak message] in
                guard let webSocketTask else { return }
                do {
                    for try await receivedMessage in webSocketTask.messages() {
                        message?.send(receivedMessage)
                    }
                } catch let error as NSError {
                    // PING ERR Error Domain=NSPOSIXErrorDomain Code=53 "Software caused connection abort" UserInfo={NSDescription=Software caused connection abort}
                    // error    NSURLError    domain: "NSPOSIXErrorDomain" - code: 57    0x0000600000cda730
                    logger.warning("ERROR \(error.localizedDescription)")
                    message?.send(completion: .failure(error))
                } catch {
                    logger.warning("ERROR \(error)")
                    message?.send(completion: .failure(error))
                }
            }
        )
    }

    func startPing() {
        pingTimerCanceller = Timer.publish(every: 20, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                self?.sendPing()
        })
    }
    
    func sendPing() {
        let host = url.host()!
        logger.info("PING \(host)")
        webSocketTask!.sendPing(pongReceiveHandler: { [weak message] error in
            if let error {
                logger.warning("PING ERR \(error)")
                message?.send(completion: .failure(error))
            } else {
                logger.info("PING OK")
            }
        })
    }
}

public struct WebSocketCloseError: Error {
    public let closeCode: URLSessionWebSocketTask.CloseCode
}

public struct WebSocketPingError: Error {
    public let state: URLSessionTask.State
}

extension URLSessionWebSocketTask {
    @PingActor
    func sendPing() async throws {
        if let error {
            throw error
        }
        if state != .running {
            throw WebSocketPingError(state: state)
        }
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

@globalActor
struct PingActor {
  actor ActorType { }

  static let shared: ActorType = ActorType()
}

