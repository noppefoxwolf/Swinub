import Foundation

public final class SwinubDefaults: Sendable {
    @MainActor
    public static var session: any Session = URLSession.shared
}
