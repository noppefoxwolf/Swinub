import Foundation
import HTTPTypes

//https://docs.joinmastodon.org/methods/statuses/#create
public struct PostV1Statuses: HTTPEndpointRequest, Sendable {
    public typealias Response = Status

    public struct Parameters: Sendable {
        public init() {}
        public var status: String = ""
        public var visibility: StatusVisibility? = nil
        public var inReplyToId: Status.ID? = nil
        public var mediaIDs: [MediaAttachment.ID]? = nil
        public var sensitive: Bool = false
        public var spoilerText: String? = nil
        public var pollOptions: [String]? = nil
        public var pollExpiresIn: Int? = nil
        public var language: Locale.Language? = nil
    }

    public init(parameters: Parameters, authorization: Authorization) {
        self.authorization = authorization
        self._parameters = parameters
    }
    public var authorization: Authorization
    var _parameters: Parameters
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/statuses" }
    public var body: EndpointRequestBody? {
        .json([
            "status": _parameters.status,
            "visibility": _parameters.visibility?.rawValue as Any,
            "in_reply_to_id": _parameters.inReplyToId?.rawValue as Any,
            // JSONの場合はmedia_ids、multipartの場合はmedia_ids[]をキーにする
            "media_ids": _parameters.mediaIDs?.map(\.rawValue) as Any,
            "sensitive": _parameters.sensitive,
            "spoiler_text": _parameters.spoilerText as Any,
            "poll": pollParameters as Any,
            "language": _parameters.language?.languageCode?.identifier as Any,
        ])
    }

    var pollParameters: [String: Any]? {
        guard let pollOptions = _parameters.pollOptions else { return nil }
        guard let expiresIn = _parameters.pollExpiresIn else { return nil }
        return [
            "options": pollOptions.filter({ !$0.isEmpty }),
            "expires_in": expiresIn,
            "multiple": false,
        ]
    }
}
