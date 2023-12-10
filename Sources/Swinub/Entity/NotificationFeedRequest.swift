public protocol NotificationFeedAuthorizationRequest: AuthorizationRequest where Response == [Notification] {
    var minID: String? { get set }
    var maxID: String? { get set }
    var limit: Int { get set }
}
