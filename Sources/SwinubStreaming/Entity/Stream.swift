import Foundation
import Swinub

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

