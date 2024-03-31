import Swinub

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
    // case ownVotes
}
