import Foundation
import HTTPTypes

public struct PostV1AccountsFollow: HTTPEndpointRequest, Sendable {
    public typealias Response = Relationship

    public init(
        id: Account.ID,
        reblogs: Bool = true,
        notify: Bool = false,
        languages: [String]? = nil,
        authorization: Authorization
    ) {
        self.accountID = id
        self.reblogs = reblogs
        self.notify = notify
        self.languages = languages
        self.authorization = authorization
    }

    public let accountID: Account.ID
    public let reblogs: Bool
    public let notify: Bool
    public let languages: [String]?
    public var byAccountID: Account.ID { authorization.accountID }
    public var authorization: Authorization
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/accounts/\(accountID)/follow" }
    public let method: HTTPRequest.Method = .post
    
    public var body: EndpointRequestBody? {
        var jsonObject: [String: Any] = [
            "reblogs": reblogs,
            "notify": notify
        ]
        
        if let languages = languages, !languages.isEmpty {
            jsonObject["languages"] = languages
        }
        
        return .json(jsonObject)
    }
}
