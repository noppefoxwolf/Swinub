import Foundation
import HTTPTypes

public struct DeleteV2FiltersKeywords: AuthorizationRequest, Sendable {
    public typealias Response = DeleteV2FiltersKeywordsResponse

    public init(
        authorization: Authorization,
        keywordID: String
    ) {
        self.authorization = authorization
        self.keywordID = keywordID
    }
    public let authorization: Authorization
    let keywordID: String
    
    public var authority: String { authorization.host }
    public var path: String { "/api/v2/filters/keywords/\(keywordID)" }
    public let method: RequestMethod = .delete
}

public struct DeleteV2FiltersKeywordsResponse: Codable, Sendable {}
