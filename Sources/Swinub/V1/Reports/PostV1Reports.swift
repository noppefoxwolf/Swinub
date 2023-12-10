import Foundation
import HTTPTypes

public struct PostV1Reports: AuthorizationRequest {
    public typealias Response = Report

    public init(accountID: Account.ID, authorization: Authorization) {
        self.authorization = authorization
        self.accountID = accountID
    }
    public var authorization: Authorization
    public let accountID: Account.ID
    public var comment: String = ""
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/reports" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "account_id": accountID.rawValue,
            "comment": comment,
        ]
    }
}
