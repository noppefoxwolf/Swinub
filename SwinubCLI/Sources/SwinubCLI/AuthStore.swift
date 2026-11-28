import ArgumentParser
import Foundation
import Swinub

struct StoredAuth: Codable, Sendable, Equatable {
    let host: String
    let accountID: String
    let username: String
    let accessToken: String

    var key: String {
        "\(username)@\(host)"
    }

    var displayHandle: String {
        "@\(username)@\(host)"
    }
}

enum AuthStoreError: LocalizedError {
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode credentials."
        case .decodingFailed:
            return "Failed to decode credentials from Keychain."
        }
    }
}

struct AuthStore: Sendable {
    static let defaultService = "dev.noppe.swinub-cli.auth"
    static let defaultDefaultsSuite = "dev.noppe.swinub-cli"
    private static let activeAccountKey = "activeAccount"

    let keychain: KeychainStore
    let defaultsSuite: String

    init(
        service: String = AuthStore.defaultService,
        defaultsSuite: String = AuthStore.defaultDefaultsSuite
    ) {
        self.keychain = KeychainStore(service: service)
        self.defaultsSuite = defaultsSuite
    }

    private var defaults: UserDefaults {
        UserDefaults(suiteName: defaultsSuite) ?? .standard
    }

    func save(_ auth: StoredAuth) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(auth)
        } catch {
            throw AuthStoreError.encodingFailed
        }
        try keychain.set(data, forAccount: auth.key)
    }

    func list() throws -> [StoredAuth] {
        let accounts = try keychain.allAccounts()
        return try accounts
            .compactMap { try load(accountKey: $0) }
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
    }

    func load(accountKey: String) throws -> StoredAuth? {
        guard let data = try keychain.data(forAccount: accountKey) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(StoredAuth.self, from: data)
        } catch {
            throw AuthStoreError.decodingFailed
        }
    }

    func delete(accountKey: String) throws {
        try keychain.remove(account: accountKey)
        if activeAccountKeyValue() == accountKey {
            setActiveAccountKey(nil)
        }
    }

    func deleteAll() throws {
        try keychain.removeAll()
        setActiveAccountKey(nil)
    }

    func activeAccountKeyValue() -> String? {
        defaults.string(forKey: Self.activeAccountKey)
    }

    func setActiveAccountKey(_ key: String?) {
        if let key {
            defaults.set(key, forKey: Self.activeAccountKey)
        } else {
            defaults.removeObject(forKey: Self.activeAccountKey)
        }
    }

    func activeAuth() throws -> StoredAuth? {
        if let key = activeAccountKeyValue(), let auth = try load(accountKey: key) {
            return auth
        }
        return nil
    }

    func resolveAuthorization(
        host: String?,
        accessToken: String?
    ) async throws -> Authorization {
        let envToken = ProcessInfo.processInfo.environment["SWINUB_ACCESS_TOKEN"]
        let explicitToken = [accessToken, envToken].compactMap { $0 }.first { !$0.isEmpty }

        if let explicitToken {
            let resolvedHost: String
            if let host, !host.isEmpty {
                resolvedHost = host
            } else if let active = try activeAuth() {
                resolvedHost = active.host
            } else {
                throw ValidationError("Missing host. Pass --host or log in with 'swinub-cli auth login'.")
            }

            let placeholderAuthorization = Authorization(
                host: resolvedHost,
                accountID: Account.ID(rawValue: ""),
                oauthToken: explicitToken
            )
            let account = try await SwinubDefaults.session.response(
                for: GetV1AccountsVerifyCredentials(authorization: placeholderAuthorization)
            ).response

            return Authorization(
                host: resolvedHost,
                accountID: account.id,
                oauthToken: explicitToken
            )
        }

        if let active = try activeAuth() {
            if let host, !host.isEmpty, host.caseInsensitiveCompare(active.host) != .orderedSame {
                throw ValidationError(
                    "Active account is on \(active.host), not \(host). Switch accounts with 'swinub-cli auth switch' or pass --access-token."
                )
            }
            return Authorization(
                host: active.host,
                accountID: Account.ID(rawValue: active.accountID),
                oauthToken: active.accessToken
            )
        }

        throw ValidationError(
            "Missing access token. Log in with 'swinub-cli auth login', pass --access-token, or set SWINUB_ACCESS_TOKEN."
        )
    }
}
