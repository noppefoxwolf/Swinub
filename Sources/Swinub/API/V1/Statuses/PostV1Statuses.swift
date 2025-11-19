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
        public var quoteApprovalPolicy: QuoteApprovalPolicy? = nil
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
        var body: [String: Any] = [:]
        body["status"] = _parameters.status
        if let value = _parameters.visibility?.rawValue {
            body["visibility"] = value
        }
        if let value = _parameters.inReplyToId?.rawValue {
            body["in_reply_to_id"] = value
        }
        if let value = _parameters.mediaIDs?.map(\.rawValue), !value.isEmpty {
            body["media_ids"] = value
        }
        body["sensitive"] = _parameters.sensitive
        if let value = _parameters.spoilerText {
            body["spoiler_text"] = value
        }
        if let value = pollParameters {
            body["poll"] = value
        }
        if let value = _parameters.language?.languageCode?.identifier {
            body["language"] = value
        }
        if let value = _parameters.quoteApprovalPolicy {
            body["quote_approval_policy"] = value.rawValue
        }
        return .json(body as Any)
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
