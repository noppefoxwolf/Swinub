import Foundation
import HTTPTypes

public struct PostV1StatusesTranslate: AuthorizationRequest, Sendable {
    public typealias Response = Translate
    
    /// ISO 639 language code
    public init(id: Status.ID, lang: String? = nil, authorization: Authorization) {
        self.authorization = authorization
        self.statusID = id
        self.lang = lang
    }
    
    public let authorization: Authorization
    public let statusID: Status.ID
    let lang: String?
    public var authority: String { authorization.host }
    public let method: RequestMethod = .http(.post)
    public var path: String { "/api/v1/statuses/\(statusID)/translate" }
    public var parameters: [String : (any RequestParameterValue)?] {
        [
            "lang": lang
        ]
    }
}

public struct Translate: Codable, Sendable {
    public let content: String
    public let detectedSourceLanguage: String
    public let provider: String
}
