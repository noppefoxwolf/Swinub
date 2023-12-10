import AsyncAlgorithms
import Combine
import Foundation

public struct Streaming: Sendable {
    let stream: Stream
    let webSocket: WebSocket
    let decoder: JSONDecoder

    public var message: AnyPublisher<Message, Never> {
        webSocket.message
            .compactMap { message -> Message? in
                guard case .string(let string) = message else { return nil }
                do {
                    return try decoder.decode(
                        Message.self,
                        from: Data(string.utf8)
                    )
                } catch {
                    print(#function, string)
                    print(#function, error)
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    public init?(endpoint: String, stream: Stream, authorization: Authorization) {
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
