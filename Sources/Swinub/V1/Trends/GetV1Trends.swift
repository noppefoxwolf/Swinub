import Foundation
import HTTPTypes

public struct GetV1Trends: Request, Sendable {
    public typealias Response = [Tag]

    public init(host: String) {
        self.host = host
    }

    let host: String
    
    public var authority: String { host }
    public let method: HTTPRequest.Method = .get
    public var path: String { "/api/v1/trends" }
}
