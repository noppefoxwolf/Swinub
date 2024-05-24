import Foundation
import HTTPTypes

public struct PostV2Filter: AuthorizationRequest, Sendable {
    public typealias Response = Filter

    public init(
        authorization: Authorization,
        title: String,
        context: [FilterContext],
        filterAction: FilterAction,
        expiresIn: Int?,
        keywordsAttributes: [KeywordsAttribute]
    ) {
        self.authorization = authorization
        self.title = title
        self.context = context
        self.filterAction = filterAction
        self.expiresIn = expiresIn
        self.keywordsAttributes = keywordsAttributes
    }
    public let authorization: Authorization
    let title: String
    let context: [FilterContext]
    let filterAction: FilterAction
    let expiresIn: Int?
    let keywordsAttributes: [KeywordsAttribute]
    
    public var authority: String { authorization.host }
    public var path: String { "/api/v2/filters" }
    public let method: RequestMethod = .post
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "title": title,
            "context": context.map(\.rawValue) as [any RequestParameterValue],
            "filter_action": filterAction.rawValue,
            "expires_in": expiresIn.map(String.init),
            "keywords_attributes": keywordsAttributes.map({ keywordsAttribute in
                [
                    "keyword": keywordsAttribute.keyword,
                    "whole_word": keywordsAttribute.wholeWord,
                ] as [String: Any]
            }),
        ] as [String: (any RequestParameterValue)?]
    }
}
