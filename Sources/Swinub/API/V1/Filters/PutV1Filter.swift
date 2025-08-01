import Foundation
import HTTPTypes

public struct PutV1Filter: HTTPEndpointRequest, Sendable {
    public typealias Response = FilterV1

    public init(
        authorization: Authorization,
        filterID: String,
        phrase: String,
        context: [FilterContextV1],
        irreversible: Bool = false,
        wholeWord: Bool = false,
        expiresIn: Int? = nil
    ) {
        self.authorization = authorization
        self.filterID = filterID
        self.phrase = phrase
        self.context = context
        self.irreversible = irreversible
        self.wholeWord = wholeWord
        self.expiresIn = expiresIn
    }
    public let authorization: Authorization
    let filterID: String
    let phrase: String
    let context: [FilterContextV1]
    let irreversible: Bool
    let wholeWord: Bool
    let expiresIn: Int?
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/filters/\(filterID)" }
    public let method: HTTPRequest.Method = .put
    public var body: EndpointRequestBody? {
        .json([
            "phrase": phrase,
            "context": context.map(\.rawValue).joined(separator: ","),
            "irreversible": "\(irreversible)",
            "wholeWord": "\(wholeWord)",
            "expires_in": expiresIn.map(String.init) as Any,
        ])
    }
}
