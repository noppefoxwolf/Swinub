import AsyncAlgorithms
import Combine
import Foundation
import Swinub

public struct Streaming: Sendable {
    let stream: Stream
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
    
    public init?(endpoint: String, stream: Stream, authorization: Swinub.Authorization) {
        self.stream = stream
        let path = "\(endpoint)/api/v1/streaming"
        var urlComponents = URLComponents(string: path)
        // https://docs.joinmastodon.org/methods/streaming/#streams
        urlComponents?.queryItems = [
            URLQueryItem(name: "access_token", value: authorization.oauthToken),
            URLQueryItem(name: "stream", value: stream.rawValue),
        ]
        guard let url = urlComponents?.url else { return nil }
        webSocket = WebSocket(
            url: url,
            authorization: "Bearer \(authorization.oauthToken)"
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
