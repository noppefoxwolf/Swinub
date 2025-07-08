import Foundation
import CoreTransferable
import HTTPTypes

// https://docs.joinmastodon.org/methods/accounts/#update_credentials
public struct PatchV1AccountsUpdateCredentials: HTTPEndpointRequest, Sendable {
    public typealias Response = Account

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization

    public var displayName: String? = nil
    public var avatar: (any Transferable & Sendable)? = nil
    public var header: (any Transferable & Sendable)? = nil

    public var authority: String { authorization.host }
    public var path: String { "/api/v1/accounts/update_credentials" }
    public let method: HTTPRequest.Method = .patch
    
    public var body: EndpointRequestBody? {
        .multipart([
            MultipartFormItem(name: "display_name", value: displayName),
            MultipartFormItem(name: "avatar", value: avatar),
            MultipartFormItem(name: "header", value: header),
        ])
    }
}
