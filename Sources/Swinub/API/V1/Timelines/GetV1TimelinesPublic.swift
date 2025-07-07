import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/timelines/#see-also
public struct GetV1TimelinesPublic: HTTPEndpointRequest, Sendable {
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
    public let method: HTTPRequest.Method = .get
    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if _parameters.local {
            items.append(URLQueryItem(name: "local", value: "true"))
        }
        if _parameters.remote {
            items.append(URLQueryItem(name: "remote", value: "true"))
        }
        if let domain = _parameters.domain {
            items.append(URLQueryItem(name: "domain", value: domain))
        }
        if _parameters.onlyMedia {
            items.append(URLQueryItem(name: "only_media", value: "true"))
        }
        items.append(URLQueryItem(name: "limit", value: String(limit)))
        if let sinceID = sinceID?.rawValue {
            items.append(URLQueryItem(name: "since_id", value: sinceID))
        }
        if let maxID = nextCursor?.maxID {
            items.append(URLQueryItem(name: "max_id", value: maxID))
        }
        if let minID = prevCursor?.minID {
            items.append(URLQueryItem(name: "min_id", value: minID))
        }
        return items
    }
}
