import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/media/#v2
public struct PostV2Media: HTTPEndpointRequest, Sendable {
    public typealias Response = MediaAttachment

    public init(
        authorization: Authorization,
        media: any UploadMedia & RequestParameterValue & Sendable
    ) {
        self.authorization = authorization
        self.media = media
    }

    public let authorization: Authorization
    let media: any UploadMedia & RequestParameterValue & Sendable
    public var description: String?
    
    public var authority: String { authorization.host }
    public var path: String { "/api/v2/media" }
    public let method: HTTPRequest.Method = .post
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "file": media,
            "description": description
        ]
    }
}
