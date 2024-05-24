import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/preferences/
public struct GetV1Preferences: AuthorizationRequest, Sendable {
    public typealias Response = Preference

    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization
    public var authority: String { authorization.host }
    public let method: RequestMethod = .http(.get)
    public var path: String { "/api/v1/preferences" }
}
