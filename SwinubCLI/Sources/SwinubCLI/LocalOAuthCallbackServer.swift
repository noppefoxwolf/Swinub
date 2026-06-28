import ArgumentParser
import Foundation
import Hummingbird
import Logging

struct LocalOAuthCallbackServer: Sendable {
    private let port: Int
    private let path: String

    init(port: UInt16, path: String) throws {
        guard port > 0 else {
            throw ValidationError("Invalid callback port.")
        }

        self.port = Int(port)
        self.path = path
    }

    func waitForCode() async throws -> String {
        let (stream, continuation) = AsyncThrowingStream.makeStream(of: String.self)
        let router = Router()

        router.get(RouterPath(path)) { request, context in
            let callback = try request.uri.decodeQuery(as: CallbackQuery.self, context: context)

            if let error = callback.error {
                throw HTTPError(.badRequest, message: "Authorization failed: \(error)")
            }

            guard let code = callback.code, !code.isEmpty else {
                throw HTTPError(.badRequest, message: "Callback did not include an authorization code.")
            }

            continuation.yield(code)
            continuation.finish()
            return "Authorization complete. You can close this window."
        }

        var logger = Logger(label: "dev.noppe.SwinubCLI.local-oauth-callback")
        logger.logLevel = .critical
        let app = Application(
            router: router,
            configuration: .init(address: .hostname("127.0.0.1", port: port)),
            logger: logger
        )
        return try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                try await app.runService(gracefulShutdownSignals: [])
                throw ValidationError("Callback server stopped before receiving an authorization code.")
            }

            group.addTask {
                guard let code = try await stream.first(where: { _ in true }) else {
                    throw ValidationError("Callback server stopped before receiving an authorization code.")
                }
                return code
            }

            guard let code = try await group.next() else {
                throw ValidationError("Callback server stopped before receiving an authorization code.")
            }
            group.cancelAll()
            return code
        }
    }
}

private struct CallbackQuery: Decodable {
    let code: String?
    let error: String?
}
