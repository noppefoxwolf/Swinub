import Foundation
import HTTPTypes

public struct MapAuthorizationRequest<Response: Codable & Sendable, Base: AuthorizationRequest>: AuthorizationRequest {
    public var base: Base
    let transform: @Sendable (Base.Response) throws -> Response
    
    init(base: Base, transform: @escaping @Sendable (Base.Response) throws -> Response) {
        self.base = base
        self.transform = transform
    }
    
    public var method: RequestMethod { base.method }
    public var authorization: Authorization { base.authorization }
    public var scheme: String { base.scheme }
    public var authority: String { base.authority }
    public var path: String { base.path }
    public var url: URL { get throws { try base.url } }
    public var parameters: [String: (any RequestParameterValue)?] { base.parameters }
    public func makeURLRequest() throws -> URLRequest { try base.makeURLRequest() }
    public func decode(_ data: Data) throws -> Response {
        let response = try base.decode(data)
        return try transform(response)
    }
}

extension AuthorizationRequest {
    public func map<T: Codable>(_ transform: @escaping @Sendable (Self.Response) throws -> T) -> MapAuthorizationRequest<T, Self> {
        MapAuthorizationRequest(base: self, transform: transform)
    }
}
