public protocol TimelineAuthorizationRequest: AuthorizationRequest where Response == [Status] {
    var path: String { get }
    var sinceID: String? { get set }
    var nextCursor: NextCursor? { get set }
    var prevCursor: PrevCursor? { get set }
    var limit: Int { get set }
}
