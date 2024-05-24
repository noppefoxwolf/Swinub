import Foundation
import HTTPTypes

public struct PostV2FiltersKeywords: AuthorizationRequest, Sendable {
    public typealias Response = FilterKeyword

    public init(
        authorization: Authorization,
        filterID: String,
        keywordsAttribute: KeywordsAttribute
    ) {
        self.authorization = authorization
        self.filterID = filterID
        self.keywordsAttribute = keywordsAttribute
    }
    public let authorization: Authorization
    let filterID: String
    let keywordsAttribute: KeywordsAttribute
    
    public var authority: String { authorization.host }
    public var path: String { "/api/v2/filters/\(filterID)/keywords" }
    public let method: RequestMethod = .http(.post)
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "keyword": keywordsAttribute.keyword,
            "whole_word": keywordsAttribute.wholeWord,
        ]
    }
}
