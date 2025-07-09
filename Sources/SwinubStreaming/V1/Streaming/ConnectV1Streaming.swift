import CoreTransferable
import Foundation
import HTTPTypes
import Swinub

public struct ConnectV1Streaming: StreamingEndpointRequest {
    public typealias Response = Message

    let stream: StreamQuery
    let host: String
    public var authorization: Authorization?
    public var authority: String { authorization?.host ?? host }
    public let path: String = "/api/v1/streaming"

    public var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "access_token", value: authorization?.oauthToken),
            URLQueryItem(name: "stream", value: stream.stream.rawValue),
        ]
        if let name = stream.queryItem?.name, let value = stream.queryItem?.value {
            let item = URLQueryItem(name: name, value: value)
            items.append(item)
        }
        return items
    }

    public var body: EndpointRequestBody? { nil }

    public init(stream: StreamQuery, host: String) {
        self.host = host
        self.stream = stream
    }
}
