import Foundation

public final class SwinubDefaults: @unchecked Sendable {
    @MainActor
    public static var session: any Session = URLSession.shared
}
