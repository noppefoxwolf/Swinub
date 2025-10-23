import Foundation
import HTTPTypes

public struct PostV1AccountsSubscribe: HTTPEndpointRequest, Sendable {
    public typealias Response = Relationship

    public init(id: Account.ID, authorization: Authorization) {
        self.accountID = id
        self.authorization = authorization
    }

    public let accountID: Account.ID
    public var byAccountID: Account.ID { authorization.accountID }
    public var authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/accounts/\(accountID)/subscribe" }
    public let method: HTTPRequest.Method = .post

    public var reblogs: Bool?
    public var mediaOnly: Bool?
    public var listID: List.ID?

    public var body: EndpointRequestBody? {
        var json: [String: Any] = [:]

        if let reblogs {
            json["reblogs"] = reblogs
        }

        if let mediaOnly {
            json["media_only"] = mediaOnly
        }

        if let listID {
            json["list_id"] = listID.rawValue
        }

        return json.isEmpty ? nil : .json(json)
    }
}
