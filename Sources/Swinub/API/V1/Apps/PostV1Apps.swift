import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/apps/
public struct PostV1Apps: HTTPEndpointRequest, Sendable {
    public typealias Response = Application

    public init(
        host: String,
        clientName: String,
        redirectURI: String,
        website: String? = nil,
        scopes: [Scope] = [.read]
    ) {
        self.host = host
        self.clientName = clientName
        self.redirectURI = redirectURI
        self.website = website
        self.scopes = scopes
    }
    var host: String
    var clientName: String
    var redirectURI: String
    var website: String?
    var scopes: [Scope]
    public var authority: String { host }
    public var path: String { "/api/v1/apps" }
    public let method: HTTPRequest.Method = .post
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "client_name": clientName,
            "redirect_uris": redirectURI,
            "website": website,
            "scopes": scopes.map(\.rawValue).joined(separator: " "),
        ]
    }
}
