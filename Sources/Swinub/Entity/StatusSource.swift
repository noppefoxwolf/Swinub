// https://docs.joinmastodon.org/entities/StatusSource/
public struct StatusSource: Codable, Sendable {
    public let id: Status.ID
    public let text: String
    public let spoilerText: String
}
