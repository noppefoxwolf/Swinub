import Foundation
import CoreTransferable
import HTTPTypes

// https://docs.joinmastodon.org/methods/media/#v2
public struct PostV2Media: HTTPEndpointRequest, Sendable {
    public typealias Response = MediaAttachment

    public init(
        authorization: Authorization,
        media: any Transferable & Sendable
    ) {
        self.authorization = authorization
        self.media = media
    }

    public let authorization: Authorization
    let media: any Transferable & Sendable
    public var description: String?
    
    public var authority: String { authorization.host }
    public var path: String { "/api/v2/media" }
    public let method: HTTPRequest.Method = .post
    
    public var body: EndpointRequestBody? {
        .multipart([
            MultipartFormItem(name: "file", value: media),
            MultipartFormItem(name: "description", value: description),
        ])
    }
}
