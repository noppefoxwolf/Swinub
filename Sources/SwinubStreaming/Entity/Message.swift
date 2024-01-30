import Swinub
import Foundation

public struct Message: Decodable, Sendable {
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
            event = .delete(statusID: .init(rawValue: payload))
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

