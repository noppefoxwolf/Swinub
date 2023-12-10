import Foundation
import HTTPTypes

public struct GetV1Media: AuthorizationRequest {
    public typealias Response = MediaAttachment

    public init(authorization: Authorization, mediaAttachmentID: String) {
        self.authorization = authorization
        self.mediaAttachmentID = mediaAttachmentID
    }

    public let authorization: Authorization
    let mediaAttachmentID: String
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/media/\(mediaAttachmentID)" }
}
