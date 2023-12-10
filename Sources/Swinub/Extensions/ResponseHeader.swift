import Foundation
import HTTPTypes

public extension HTTPField.Name {
    static let link = Self("Link")!
    static let limit = Self("X-RateLimit-Limit")!
    static let remaining = Self("X-RateLimit-Remaining")!
    static let reset = Self("X-RateLimit-Reset")!
}
