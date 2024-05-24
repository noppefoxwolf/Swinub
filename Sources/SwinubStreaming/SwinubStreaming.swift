import Foundation
import Swinub

public extension SwinubDefaults {
    @MainActor
    static var streamingSession: any StreamingSession = URLSession.shared
}
