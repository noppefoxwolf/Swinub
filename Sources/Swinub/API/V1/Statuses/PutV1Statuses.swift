import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/statuses/#edit
public struct PutV1Statuses: HTTPEndpointRequest, Sendable {
    public typealias Response = Status

    public struct Parameters: Sendable {
        public init() {}

        /// The plain text content of the status.
        public var status: String? = nil
        /// The plain text subject or content warning of the status.
        public var spoilerText: String? = nil
        /// Whether the status should be marked as sensitive.
        public var sensitive: Bool? = nil
        /// ISO 639-1 language code for the status.
        public var language: Locale.Language? = nil
        /// Attachment IDs to be attached as media.
        public var mediaIDs: [MediaAttachment.ID]? = nil
        /// Possible answers to the poll.
        public var pollOptions: [String]? = nil
        /// Duration that the poll should be open, in seconds.
        public var pollExpiresIn: Int? = nil
        /// Allow multiple choices in the poll.
        public var pollMultiple: Bool? = nil
        /// Hide vote counts until the poll ends.
        public var pollHideTotals: Bool? = nil
        /// Sets who is allowed to quote the status.
        public var quoteApprovalPolicy: QuoteApprovalPolicy? = nil
    }

    public init(
        statusID: Status.ID,
        parameters: Parameters,
        authorization: Authorization
    ) {
        self.statusID = statusID
        self.parameters = parameters
        self.authorization = authorization
    }

    public let statusID: Status.ID
    public let parameters: Parameters
    public let authorization: Authorization
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .put
    public var path: String { "/api/v1/statuses/\(statusID)" }

    public var body: EndpointRequestBody? {
        var body: [String: Any] = [:]

        if let value = parameters.status {
            body["status"] = value
        }
        if let value = parameters.spoilerText {
            body["spoiler_text"] = value
        }
        if let value = parameters.sensitive {
            body["sensitive"] = value
        }
        if let value = parameters.language?.languageCode?.identifier {
            body["language"] = value
        }
        if let value = parameters.mediaIDs {
            body["media_ids"] = value.map(\.rawValue)
        }
        if let poll = pollParameters {
            body["poll"] = poll
        }
        if let value = parameters.quoteApprovalPolicy {
            body["quote_approval_policy"] = value.rawValue
        }

        return .json(body)
    }

    private var pollParameters: [String: Any]? {
        guard let pollOptions = parameters.pollOptions,
              let expiresIn = parameters.pollExpiresIn else {
            return nil
        }

        var poll: [String: Any] = [
            "options": pollOptions.filter { !$0.isEmpty },
            "expires_in": expiresIn,
        ]
        if let value = parameters.pollMultiple {
            poll["multiple"] = value
        }
        if let value = parameters.pollHideTotals {
            poll["hide_totals"] = value
        }
        return poll
    }
}
