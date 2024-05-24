import Foundation
import HTTPTypes

public struct GetV1Media: AuthorizationRequest, Sendable {
    public typealias Response = MediaAttachment

    public init(authorization: Authorization, id: MediaAttachment.ID) {
        self.authorization = authorization
        self.mediaAttachmentID = id
    }

    public let authorization: Authorization
    let mediaAttachmentID: MediaAttachment.ID
    public var authority: String { authorization.host }
    public let method: RequestMethod = .get
    public var path: String { "/api/v1/media/\(mediaAttachmentID.rawValue)" }
}
