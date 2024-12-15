import Foundation
import HTTPTypes

public struct MapHTTPEndpointRequest<Response: Codable & Sendable, Base: HTTPEndpointRequest>: HTTPEndpointRequest {
    public typealias Response = Response
    public typealias Base = Base
    
    public var base: Base
    let transform: @Sendable (Base.Response) throws -> Response
    
    init(base: Base, transform: @escaping @Sendable (Base.Response) throws -> Response) {
        self.base = base
        self.transform = transform
    }
    
    public var method: HTTPRequest.Method { base.method }
    public var authorization: Base.AuthorizationType { base.authorization }
    public var scheme: String { base.scheme }
    public var authority: String { base.authority }
    public var path: String { base.path }
    public var url: URL { get throws { try base.url } }
    public var parameters: [String: (any RequestParameterValue)?] { base.parameters }
    public func makeHTTPRequest() throws -> (HTTPRequest, Data) { try base.makeHTTPRequest() }
    public func decode(_ data: Data) throws -> Response {
        let response = try base.decode(data)
        return try transform(response)
    }
}

extension HTTPEndpointRequest {
    public func map<T: Codable>(_ transform: @escaping @Sendable (Self.Response) throws -> T) -> MapHTTPEndpointRequest<T, Self> {
        MapHTTPEndpointRequest(base: self, transform: transform)
    }
}
