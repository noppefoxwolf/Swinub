import Swinub

// https://docs.joinmastodon.org/methods/streaming/#events
struct EventType: Codable, Sendable, Equatable {
    let rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    static var update: Self { Self.init(rawValue: "update") }
    static var delete: Self { Self.init(rawValue: "delete") }
    static var notification: Self { Self.init(rawValue: "notification") }
    static var filtersChanged: Self { Self.init(rawValue: "filtersChanged") }
    static var conversation: Self { Self.init(rawValue: "conversation") }
    static var announcement: Self { Self.init(rawValue: "announcement") }
    static var announcementReaction: Self { Self.init(rawValue: "announcement.reaction") }
    static var announcementDelete: Self { Self.init(rawValue: "announcement.delete") }
    static var statusUpdate: Self { Self.init(rawValue: "status.update") }
    static var encryptedMessage: Self { Self.init(rawValue: "encryptedMessage") }
}

public enum Event: Sendable {
    case update(Status)
    case delete(statusID: Status.ID)
    case notification(Swinub.Notification)
    case filtersChanged
    case conversation(Conversation)
    case announcement(Announcement)
    case announcementReaction
    case announcementDelete
    case statusUpdate(Status)
    case encryptedMessage
    case unknown(String)
}
