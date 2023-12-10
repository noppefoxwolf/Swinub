import Foundation

// https://docs.joinmastodon.org/methods/streaming/#events
public enum Stream: String, Codable, Sendable {
    case `public`
    case publicMedia = "public:media"
    case publicLocal = "public:local"
    case publicLocalMedia = "public:local:media"
    case publicRemote = "public:remote"
    case publicRemoteMedia = "public:remote:media"
    case hashtag
    case hashtagLocal = "hashtag:local"
    case user
    case userNotification = "user:notification"
    case list
    case direct
}

public struct Message: Decodable {
    public let stream: [Stream]
    public let event: Event

    enum CodingKeys: CodingKey {
        case stream
        case event
        case payload
    }

    public init(from decoder: any Decoder) throws {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .millisecondsISO8601

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stream = try container.decode([Stream].self, forKey: .stream)
        let eventType = try container.decode(EventType.self, forKey: .event)
        switch eventType {
        case .update:
            let payload = try container.decode(String.self, forKey: .payload)
            let status = try jsonDecoder.decode(Status.self, from: Data(payload.utf8))
            event = .update(status)
        case .delete:
            let payload = try container.decode(String.self, forKey: .payload)
            event = .delete(statusID: payload)
        case .notification:
            let payload = try container.decode(String.self, forKey: .payload)
            let notification = try jsonDecoder.decode(
                Notification.self,
                from: Data(payload.utf8)
            )
            event = .notification(notification)
        case .filtersChanged:
            event = .filtersChanged
        case .conversation:
            let payload = try container.decode(String.self, forKey: .payload)
            let conversation = try jsonDecoder.decode(
                Conversation.self,
                from: Data(payload.utf8)
            )
            event = .conversation(conversation)
        case .announcement:
            let payload = try container.decode(String.self, forKey: .payload)
            let announcement = try jsonDecoder.decode(
                Announcement.self,
                from: Data(payload.utf8)
            )
            event = .announcement(announcement)
        case .announcementReaction:
            event = .announcementReaction
        case .announcementDelete:
            event = .announcementDelete
        case .statusUpdate:
            let payload = try container.decode(String.self, forKey: .payload)
            let status = try jsonDecoder.decode(Status.self, from: Data(payload.utf8))
            event = .statusUpdate(status)
        case .encryptedMessage:
            event = .encryptedMessage
        }
    }
}

// https://docs.joinmastodon.org/methods/streaming/#events
enum EventType: String, Codable {
    case update
    case delete
    case notification
    case filtersChanged
    case conversation
    case announcement
    case announcementReaction = "announcement.reaction"
    case announcementDelete = "announcement.delete"
    case statusUpdate = "status.update"
    case encryptedMessage
}

public enum Event {
    case update(Status)
    case delete(statusID: String)
    case notification(Notification)
    case filtersChanged
    case conversation(Conversation)
    case announcement(Announcement)
    case announcementReaction
    case announcementDelete
    case statusUpdate(Status)
    case encryptedMessage
}
