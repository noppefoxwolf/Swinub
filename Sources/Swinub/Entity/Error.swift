import Foundation
import HTTPTypes

public struct MastodonError: LocalizedError, Decodable, Sendable {
    enum CodingKeys: CodingKey {
        case error
        case errorDescription
    }

    public let error: String
    public let description: String?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.error = try container.decode(String.self, forKey: .error)
        // workaround: errorDescriptionのキー名でレスポンスが来るので別名でdecodeする
        self.description = try container.decodeIfPresent(String.self, forKey: .errorDescription)
    }

    init(error: String, errorDescription: String?) {
        self.error = error
        self.description = errorDescription
    }
}

public struct GeneralError: LocalizedError, Sendable {
    public var errorDescription: String?
}

public struct SwinubError: LocalizedError, Sendable {
    public let error: any Error
    public let httpResponse: HTTPResponse

    public var errorDescription: String? {
        switch error {
        case let mastodonError as MastodonError:
            let text = mastodonError.description ?? mastodonError.error
            let messages = text.split(separator: ":")
            if messages.count > 1 {
                return messages.dropFirst().joined(separator: ":")
            } else {
                return text
            }
        case let generalError as GeneralError:
            return generalError.errorDescription
        default:
            return error.localizedDescription
        }
    }
}
