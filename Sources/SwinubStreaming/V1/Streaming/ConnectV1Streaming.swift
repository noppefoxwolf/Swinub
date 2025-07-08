import Swinub
import HTTPTypes
import Foundation
import CoreTransferable

public struct ConnectV1Streaming: StreamingEndpointRequest {
    public typealias Response = Message
    
    let stream: StreamQuery
    let host: String
    public var authorization: Authorization?
    public var authority: String { authorization?.host ?? host }
    public let path: String = "/api/v1/streaming"
    
    public var queryItems: [URLQueryItem] { [] }
    
    public var multipartFormData: [String : any Transferable] { [:] }
    
    public var parameters: [String : any RequestParameterValue] {
        var parameters: [String : (any RequestParameterValue)?] = [
            "access_token" : authorization?.oauthToken,
            "stream" : stream.stream.rawValue,
        ]
        if let name = stream.queryItem?.name, let value = stream.queryItem?.value {
            parameters[name] = value
        }
        return parameters.compactMapValues({ $0 })
    }
    
    public init(stream: StreamQuery, host: String) {
        self.host = host
        self.stream = stream
    }
}
