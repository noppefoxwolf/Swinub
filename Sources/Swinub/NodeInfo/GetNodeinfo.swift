import HTTPTypes

public struct GetNodeinfo: HTTPEndpointRequest, Sendable {
    public typealias Response = NodeInfo
    public typealias AuthorizationType = Never

    public init(link: NodeinfoLink) {
        self.link = link
    }
    
    let link: NodeinfoLink
    
    public var authority: String { link.href.host() ?? "" }
    public var path: String { link.href.path() }
    public let method: HTTPRequest.Method = .get
}
