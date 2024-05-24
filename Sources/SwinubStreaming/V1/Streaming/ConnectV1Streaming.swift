import Swinub
import HTTPTypes

public struct ConnectV1Streaming: OptionalAuthorizationRequest {
    
    
    public typealias Response = Message
    
    let stream: StreamQuery
    let host: String
    public var authorization: Authorization?
    public var authority: String { authorization?.host ?? host }
    public var method: RequestMethod = .webSocket
    public let path: String = "/api/v1/streaming"
    
    public var parameters: [String : (any RequestParameterValue)?] {
        var parameters = [
            "access_token" : authorization?.oauthToken,
            "stream" : stream.stream.rawValue,
        ]
        if let name = stream.queryItem?.name, let value = stream.queryItem?.value {
            parameters[name] = value
        }
        return parameters
    }
    
    public init(stream: StreamQuery, host: String) {
        self.host = host
        self.stream = stream
    }
}
