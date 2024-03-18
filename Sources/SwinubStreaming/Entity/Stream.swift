import Foundation
import Swinub

// https://docs.joinmastodon.org/methods/streaming/#events
public enum Stream: Codable, Sendable {
    case `public`
    case publicMedia
    case publicLocal
    case publicLocalMedia
    case publicRemote
    case publicRemoteMedia
    case hashtag(tag: String)
    case hashtagLocal(tag: String)
    case user
    case userNotification
    case list(id: String)
    case direct
    
    var streamValue: String {
        switch self {
        case .public:
            "public"
        case .publicMedia:
            "public:media"
        case .publicLocal:
            "public:local"
        case .publicLocalMedia:
            "public:local:media"
        case .publicRemote:
            "public:remote"
        case .publicRemoteMedia:
            "public:remote:media"
        case .hashtag:
            "hashtag"
        case .hashtagLocal:
            "hashtag:local"
        case .user:
            "user"
        case .userNotification:
            "user:notification"
        case .list:
            "list"
        case .direct:
            "direct"
        }
    }
    
    var queryItem: URLQueryItem? {
        switch self {
        case .hashtag(let tag), .hashtagLocal(let tag):
            URLQueryItem(name: "tag", value: tag)
        case .list(let id):
            URLQueryItem(name: "list", value: id)
        default:
            nil
        }
    }
}

