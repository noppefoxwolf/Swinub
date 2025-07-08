import Foundation
import HTTPTypes

public struct PostV1Filter: HTTPEndpointRequest, Sendable {
    public typealias Response = FilterV1

    public init(
        authorization: Authorization,
        phrase: String,
        context: [FilterContextV1],
        irreversible: Bool,
        wholeWord: Bool,
        expiresIn: Int?
    ) {
        self.authorization = authorization
        self.phrase = phrase
        self.context = context
        self.irreversible = irreversible
        self.wholeWord = wholeWord
        self.expiresIn = expiresIn
    }
    public let authorization: Authorization
    let phrase: String
    let context: [FilterContextV1]
    let irreversible: Bool
    let wholeWord: Bool
    let expiresIn: Int?
    public var authority: String { authorization.host }
    public let method: HTTPRequest.Method = .post
    public var path: String { "/api/v1/filters" }
    public var body: EndpointRequestBody? {
        .json([
            "phrase": phrase,
            "context": context.map(\.rawValue),
            "irreversible": irreversible,
            "wholeWord": wholeWord,
            "expires_in": expiresIn.map(String.init),
        ])
    }
}
