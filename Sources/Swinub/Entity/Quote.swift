import Foundation

public enum QuoteState: String, CaseIterable, Codable, Sendable {
    case pending
    case accepted
    case rejected
    case revoked
    case deleted
    case unauthorized
}

public struct Quote: Codable, Sendable {
    public let state: QuoteState
    public let quotedStatus: Indirect<Status>?

    public init(from decoder: any Decoder) throws {
        var state: QuoteState
        var quotedStatus: Indirect<Status>?

        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            state = try container.decode(QuoteState.self, forKey: .state)
            quotedStatus = try container.decodeIfPresent(
                Indirect<Status>.self,
                forKey: .quotedStatus
            )
        } catch {
            do {
                // fedibirdの場合
                let container = try decoder.singleValueContainer()
                state = .accepted
                quotedStatus = try container.decode(Indirect<Status>.self)
            } catch {
                throw error
            }
        }

        self.state = state
        self.quotedStatus = quotedStatus
    }
}
