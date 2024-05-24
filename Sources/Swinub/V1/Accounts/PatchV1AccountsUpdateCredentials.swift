import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/accounts/#update_credentials
public struct PatchV1AccountsUpdateCredentials: AuthorizationRequest, Sendable {
    public typealias Response = Account

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization

    public var displayName: String? = nil
    public var avatar: Jpeg? = nil
    public var header: Jpeg? = nil

    public var authority: String { authorization.host }
    public var path: String { "/api/v1/accounts/update_credentials" }
    public let method: RequestMethod = .patch
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "display_name": displayName,
            "avatar": avatar,
            "header": header,
        ]
    }
}
