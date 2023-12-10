public protocol RelashionshipAuthorizationRequest: AuthorizationRequest {
    var accountID: String { get }
    var byAccountID: String { get }
}

public protocol RelashionshipsRequest: Request {
    var accountIDs: [String] { get }
    var byAccountID: String { get }
}
