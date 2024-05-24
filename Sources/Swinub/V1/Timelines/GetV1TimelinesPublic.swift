import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/timelines/#see-also
public struct GetV1TimelinesPublic: AuthorizationRequest, Sendable {
    public typealias Response = [Status]

    public struct Parameters: Sendable {
        public init() {}
        public var local: Bool = false
        public var remote: Bool = false
        public var domain: String? = nil
        public var onlyMedia: Bool = false

        public static var local: Parameters {
            var parameters = Parameters()
            parameters.local = true
            return parameters
        }

        public static let federated: Parameters = .init()

        // fedibird extension
        // https://fedibird.com/@info/103266777365961665
        // https://github.com/fedibird/mastodon/blob/main/app/controllers/api/v1/timelines/public_controller.rb
        public static func domain(_ domain: String) -> Parameters {
            var parameters = Parameters()
            parameters.domain = domain
            return parameters
        }
    }

    public init(authorization: Authorization, parameters: Parameters) {
        self.authorization = authorization
        self._parameters = parameters
    }
    public let authorization: Authorization
    public var sinceID: Status.ID? = nil
    public var nextCursor: NextCursor? = nil
    public var prevCursor: PrevCursor? = nil
    public var limit: Int = 20
    let _parameters: Parameters

    public var authority: String { authorization.host }
    public let path = "/api/v1/timelines/public"
    public let method: RequestMethod = .http(.get)
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "local": _parameters.local,
            "remote": _parameters.remote,
            "domain": _parameters.domain,
            "only_media": _parameters.onlyMedia,
            "limit": limit,
            "since_id": sinceID?.rawValue,
            "max_id": nextCursor?.maxID,
            "min_id": prevCursor?.minID,
        ]
    }
}
