import ArgumentParser
import Darwin
import Foundation
import Swinub
import SwinubAuthenticationServices

struct Auth: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "auth",
        abstract: "Manage Fediverse authentication in Keychain.",
        subcommands: [Login.self, Status.self, Switch.self, Logout.self, Token.self]
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

    struct Status: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "status",
            abstract: "Show authentication status and saved accounts."
        )

        mutating func run() async throws {
            let store = AuthStore()
            let accounts = try store.list()
            let activeKey = store.activeAccountKeyValue()
            let envToken = ProcessInfo.processInfo.environment["SWINUB_ACCESS_TOKEN"]
            let hasEnvToken = envToken.map { !$0.isEmpty } ?? false

            if accounts.isEmpty {
                print("Not logged in to any accounts. Run 'swinub-cli auth login' first.")
                if hasEnvToken {
                    print("Note: SWINUB_ACCESS_TOKEN is set in environment.")
                }
                return
            }

            var foundActive = false
            for account in accounts {
                let isActive = account.key == activeKey
                if isActive {
                    foundActive = true
                    print("* \(account.displayHandle) (active)")
                } else {
                    print("  \(account.displayHandle)")
                }
            }

            if !foundActive {
                print("")
                print("No active account selected. Run 'swinub-cli auth switch' to select one.")
            }

            if hasEnvToken {
                print("")
                print("Note: SWINUB_ACCESS_TOKEN is set and overrides the active Keychain account.")
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

            let activeKey = store.activeAccountKeyValue()

            if let account {
                let normalized = normalizeAccountKey(account)
                guard let matched = accounts.first(where: { $0.key.caseInsensitiveCompare(normalized) == .orderedSame }) else {
                    throw ValidationError("Account '\(account)' not found in Keychain.")
                }
                if matched.key == activeKey {
                    print("Already using \(matched.displayHandle)")
                    return
                }
                store.setActiveAccountKey(matched.key)
                print("Switched active account to \(matched.displayHandle)")
                return
            }

            let switchableAccounts = accounts.filter { $0.key != activeKey }
            guard !switchableAccounts.isEmpty else {
                if let current = accounts.first {
                    print("Already using the only saved account: \(current.displayHandle)")
                }
                return
            }

            if let active = accounts.first(where: { $0.key == activeKey }) {
                print("Active account: \(active.displayHandle)")
                print("")
            }

            let selected: StoredAuth
            if isatty(STDIN_FILENO) != 0 && isatty(STDOUT_FILENO) != 0 {
                selected = try selectAccountInteractively(from: switchableAccounts)
            } else {
                selected = try selectAccountByNumber(from: switchableAccounts)
            }

            store.setActiveAccountKey(selected.key)
            print("Switched active account to \(selected.displayHandle)")
        }

        private func selectAccountByNumber(from accounts: [StoredAuth]) throws -> StoredAuth {
            for (index, item) in accounts.enumerated() {
                print("[\(index + 1)] \(item.displayHandle)")
            }

            print("")
            print("Select account number: ", terminator: "")
            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
                let selection = Int(input),
                (1...accounts.count).contains(selection)
            else {
                throw ValidationError("Invalid selection.")
            }

            return accounts[selection - 1]
        }

        private func selectAccountInteractively(from accounts: [StoredAuth]) throws -> StoredAuth {
            var originalTermios = termios()
            guard tcgetattr(STDIN_FILENO, &originalTermios) == 0 else {
                return try selectAccountByNumber(from: accounts)
            }

            var rawTermios = originalTermios
            rawTermios.c_lflag &= ~UInt(ICANON | ECHO)
            rawTermios.c_cc.16 = 1 // VMIN
            rawTermios.c_cc.17 = 0 // VTIME

            guard tcsetattr(STDIN_FILENO, TCSANOW, &rawTermios) == 0 else {
                return try selectAccountByNumber(from: accounts)
            }

            defer {
                tcsetattr(STDIN_FILENO, TCSANOW, &originalTermios)
            }

            var selectedIndex = 0

            func render(initial: Bool) {
                if !initial {
                    // Move cursor up to redraw the list
                    print("\u{001B}[\(accounts.count)A", terminator: "")
                }
                for (index, item) in accounts.enumerated() {
                    let prefix = index == selectedIndex ? "❯" : " "
                    print("\u{001B}[2K\r\(prefix) \(item.displayHandle)")
                }
                fflush(stdout)
            }

            print("Select account to switch to (↑/↓, Enter to confirm, Esc/q to cancel):")
            render(initial: true)

            while true {
                var byte: UInt8 = 0
                let bytesRead = read(STDIN_FILENO, &byte, 1)
                guard bytesRead == 1 else {
                    throw ValidationError("Selection cancelled.")
                }

                switch byte {
                case 0x0A, 0x0D: // Enter (LF / CR)
                    return accounts[selectedIndex]
                case 0x03, UInt8(ascii: "q"), UInt8(ascii: "Q"): // Ctrl-C, q
                    throw ValidationError("Selection cancelled.")
                case UInt8(ascii: "k"):
                    selectedIndex = (selectedIndex - 1 + accounts.count) % accounts.count
                    render(initial: false)
                case UInt8(ascii: "j"):
                    selectedIndex = (selectedIndex + 1) % accounts.count
                    render(initial: false)
                case 0x1B: // ESC or arrow key sequence
                    var seq = [UInt8](repeating: 0, count: 2)
                    var nonBlockingTermios = rawTermios
                    nonBlockingTermios.c_cc.16 = 0 // VMIN = 0
                    nonBlockingTermios.c_cc.17 = 1 // VTIME = 100ms
                    tcsetattr(STDIN_FILENO, TCSANOW, &nonBlockingTermios)
                    let n1 = read(STDIN_FILENO, &seq[0], 1)
                    let n2 = n1 == 1 ? read(STDIN_FILENO, &seq[1], 1) : 0
                    tcsetattr(STDIN_FILENO, TCSANOW, &rawTermios)

                    if n1 == 1 && n2 == 1 && seq[0] == UInt8(ascii: "[") {
                        if seq[1] == UInt8(ascii: "A") { // Up
                            selectedIndex = (selectedIndex - 1 + accounts.count) % accounts.count
                            render(initial: false)
                        } else if seq[1] == UInt8(ascii: "B") { // Down
                            selectedIndex = (selectedIndex + 1) % accounts.count
                            render(initial: false)
                        }
                    } else if n1 == 0 {
                        // Plain Escape key
                        throw ValidationError("Selection cancelled.")
                    }
                default:
                    break
                }
            }
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
