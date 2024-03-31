import AsyncAlgorithms
import Combine
import Foundation
import Swinub

public struct StreamingSession: Sendable {
    let webSocket: WebSocket
    let decoder: JSONDecoder
    
    public var message: AnyPublisher<Message, any Error> {
        webSocket.messagePublisher
            .compactMap({
                if case .string(let string) = $0 {
                    return string
                } else {
                    return nil
                }
            })
            .tryMap({ string -> Message in
                let message = try decoder.decode(
                    Message.self,
                    from: Data(string.utf8)
                )
                return message
            })
            .eraseToAnyPublisher()
    }
    
    public init(endpoint: URL, stream: StreamQuery, token: String) {
        // https://docs.joinmastodon.org/methods/streaming/#streams
        let queryItems = [
            URLQueryItem(name: "access_token", value: token),
            URLQueryItem(name: "stream", value: stream.stream.rawValue),
            stream.queryItem
        ].compactMap({ $0 })
        
        let url = endpoint
            .appending(path: "/api/v1/streaming")
            .appending(queryItems: queryItems)
        
        webSocket = WebSocket(
            url: url,
            authorization: "Bearer \(token)"
        )
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsISO8601
    }
    
    public func connect() {
        webSocket.connect()
    }
    
    public func disconnect() {
        webSocket.disconnect()
    }
}
