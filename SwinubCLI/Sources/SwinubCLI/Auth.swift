import ArgumentParser
import Foundation
import Swinub
import SwinubAuthenticationServices

struct Auth: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "auth",
        abstract: "Manage Fediverse authentication in Keychain.",
        subcommands: [Login.self, Switch.self, Logout.self, Token.self]
    )
}

extension Auth {
    struct Login: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "login",
            abstract: "Authorize a Fediverse account and save credentials to Keychain."
        )

        @Option(help: "Instance host, for example mastodon.social.")
        var host: String

        @Option(help: "Application name to register with the instance.")
        var clientName = "SwinubCLI"

        @Option(help: "Comma-separated OAuth scopes: read,write,follow,push.")
        var scopes = ScopeList(scopes: [.read])

        @Flag(help: "Open the authorization URL in the default browser.")
        var open = false

        @Option(help: "Use a local redirect callback on this port instead of OAuth out-of-band.")
        var callbackPort: UInt16?

        @Option(help: "Local redirect callback path.")
        var callbackPath = "/callback"

        mutating func run() async throws {
            let accessToken: String
            if let callbackPort {
                accessToken = try await runLocalRedirectAuth(callbackPort: callbackPort)
            } else {
                accessToken = try await runOutOfBandAuth()
            }

            let placeholderAuthorization = Authorization(
                host: host,
                accountID: Account.ID(rawValue: ""),
                oauthToken: accessToken
            )
            let account = try await SwinubDefaults.session.response(
                for: GetV1AccountsVerifyCredentials(authorization: placeholderAuthorization)
            ).response

            let storedAuth = StoredAuth(
                host: host,
                accountID: account.id.rawValue,
                username: account.username,
                accessToken: accessToken
            )

            let store = AuthStore()
            try store.save(storedAuth)
            store.setActiveAccountKey(storedAuth.key)

            print("Logged in as \(storedAuth.displayHandle)")
        }

        private func runOutOfBandAuth() async throws -> String {
            let service = OAuthOutOfBandAuthenticationService()
            let authorizationRequest = try await service.makeAuthorizationRequest(
                host: host,
                clientName: clientName,
                scopes: scopes.scopes
            )

            print("Open this URL and authorize the app:")
            print(authorizationRequest.authorizationURL.absoluteString)

            if open {
                try openInBrowser(authorizationRequest.authorizationURL)
            }

            print("")
            print("Paste authorization code: ", terminator: "")
            guard let code = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
                !code.isEmpty
            else {
                throw ValidationError("Authorization code is empty.")
            }

            let token = try await service.exchangeCode(code, for: authorizationRequest)
            return token.accessToken
        }

        private func runLocalRedirectAuth(callbackPort: UInt16) async throws -> String {
            let redirectURI = "http://127.0.0.1:\(callbackPort)\(normalizedCallbackPath())"
            let application = try await SwinubDefaults.session.response(
                for: PostV1Apps(
                    host: host,
                    clientName: clientName,
                    redirectURI: redirectURI,
                    scopes: scopes.scopes
                )
            ).response

            let authorizationURL = try WebAuthenticationSessionDataFactory(
                host: host,
                clientId: application.clientId,
                redirectUri: redirectURI,
                scopes: scopes.scopes
            ).makeURL()
            let callbackServer = try LocalOAuthCallbackServer(
                port: callbackPort,
                path: normalizedCallbackPath()
            )

            print("Open this URL and authorize the app:")
            print(authorizationURL.absoluteString)
            print("")
            print("Waiting for callback on \(redirectURI)")

            if open {
                try openInBrowser(authorizationURL)
            }

            let code = try await callbackServer.waitForCode()
            let token = try await SwinubDefaults.session.response(
                for: PostOAuthToken(
                    host: host,
                    clientId: application.clientId,
                    clientSecret: application.clientSecret,
                    redirectUri: redirectURI,
                    code: code,
                    scopes: scopes.scopes
                )
            ).response
            return token.accessToken
        }

        private func normalizedCallbackPath() -> String {
            callbackPath.hasPrefix("/") ? callbackPath : "/\(callbackPath)"
        }

        private func openInBrowser(_ url: URL) throws {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = [url.absoluteString]
            try process.run()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                throw ValidationError("Failed to open browser.")
            }
        }
    }

    struct Switch: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "switch",
            abstract: "Switch the active Fediverse account."
        )

        @Argument(help: "Account to activate (e.g. username@host or @username@host).")
        var account: String?

        mutating func run() async throws {
            let store = AuthStore()
            let accounts = try store.list()

            guard !accounts.isEmpty else {
                throw ValidationError("No saved accounts. Run 'swinub-cli auth login' first.")
            }

            if let account {
                let normalized = normalizeAccountKey(account)
                guard let matched = accounts.first(where: { $0.key.caseInsensitiveCompare(normalized) == .orderedSame }) else {
                    throw ValidationError("Account '\(account)' not found in Keychain.")
                }
                store.setActiveAccountKey(matched.key)
                print("Switched active account to \(matched.displayHandle)")
                return
            }

            let activeKey = store.activeAccountKeyValue()
            for (index, item) in accounts.enumerated() {
                let marker = item.key == activeKey ? "*" : " "
                print("\(marker) [\(index + 1)] \(item.displayHandle)")
            }

            print("")
            print("Select account number: ", terminator: "")
            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
                let selection = Int(input),
                (1...accounts.count).contains(selection)
            else {
                throw ValidationError("Invalid selection.")
            }

            let selected = accounts[selection - 1]
            store.setActiveAccountKey(selected.key)
            print("Switched active account to \(selected.displayHandle)")
        }
    }

    struct Logout: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "logout",
            abstract: "Remove saved credentials from Keychain."
        )

        @Argument(help: "Account to remove (e.g. username@host or @username@host). Defaults to the active account.")
        var account: String?

        @Flag(help: "Remove all saved accounts from Keychain.")
        var all = false

        mutating func run() async throws {
            let store = AuthStore()

            if all {
                try store.deleteAll()
                print("Logged out all accounts.")
                return
            }

            if let account {
                let normalized = normalizeAccountKey(account)
                let accounts = try store.list()
                guard let matched = accounts.first(where: { $0.key.caseInsensitiveCompare(normalized) == .orderedSame }) else {
                    throw ValidationError("Account '\(account)' not found in Keychain.")
                }
                try store.delete(accountKey: matched.key)
                print("Logged out \(matched.displayHandle)")
                return
            }

            guard let active = try store.activeAuth() else {
                throw ValidationError("No active account to log out. Specify an account or run 'swinub-cli auth switch'.")
            }

            try store.delete(accountKey: active.key)
            print("Logged out \(active.displayHandle)")
        }
    }

    struct Token: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "token",
            abstract: "Print the active username and access token."
        )

        mutating func run() async throws {
            let store = AuthStore()
            guard let active = try store.activeAuth() else {
                throw ValidationError("No active account. Run 'swinub-cli auth login' or 'swinub-cli auth switch'.")
            }

            print("username: \(active.displayHandle)")
            print("token: \(active.accessToken)")
        }
    }
}

private func normalizeAccountKey(_ input: String) -> String {
    if input.hasPrefix("@") {
        return String(input.dropFirst())
    }
    return input
}
