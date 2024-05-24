import Swinub
import HTTPTypes

public struct ConnectV1Streaming: AuthorizationRequest {
    public typealias Response = Message
    
    let stream: StreamQuery
    public var authorization: Authorization
    public var authority: String { authorization.host }
    public var method: HTTPTypes.HTTPRequest.Method = .connect
    public let path: String = "/api/v1/streaming"
    
    public var parameters: [String : (any RequestParameterValue)?] {
        var parameters = [
            "access_token" : authorization.oauthToken,
            "stream" : stream.stream.rawValue,
        ]
        if let name = stream.queryItem?.name, let value = stream.queryItem?.value {
            parameters[name] = value
        }
        return parameters
    }
}
