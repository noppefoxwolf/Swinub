import ArgumentParser
import Foundation
import Security
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
    case keychainError(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode credentials."
        case .decodingFailed:
            return "Failed to decode credentials from Keychain."
        case .keychainError(let status):
            if status == errSecInteractionNotAllowed {
                return "Keychain error (\(status)): User interaction is not allowed. Your login keychain may be locked; run 'security unlock-keychain' and try again."
            }
            if let message = SecCopyErrorMessageString(status, nil) as String? {
                return "Keychain error (\(status)): \(message)"
            }
            return "Keychain error (\(status))."
        }
    }
}

struct AuthStore: Sendable {
    static let defaultService = "dev.noppe.swinub-cli.auth"
    static let defaultDefaultsSuite = "dev.noppe.swinub-cli"
    private static let activeAccountKey = "activeAccount"

    let service: String
    let defaultsSuite: String

    init(
        service: String = AuthStore.defaultService,
        defaultsSuite: String = AuthStore.defaultDefaultsSuite
    ) {
        self.service = service
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

        let payload = data.base64EncodedString()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = [
            "add-generic-password",
            "-s", service,
            "-a", auth.key,
            "-w", payload,
            "-U",
            "-T", "",
        ]

        let stderrPipe = Pipe()
        process.standardError = stderrPipe
        process.standardOutput = FileHandle.nullDevice

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            let stderrText = String(data: stderrData, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if stderrText.contains("User interaction is not allowed") || stderrText.contains("-25308") {
                throw AuthStoreError.keychainError(errSecInteractionNotAllowed)
            }
            throw ValidationError(
                stderrText.isEmpty
                    ? "Failed to save credentials to Keychain (exit \(process.terminationStatus))."
                    : "Failed to save credentials to Keychain: \(stderrText)"
            )
        }
    }

    func list() throws -> [StoredAuth] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return []
        }
        guard status == errSecSuccess else {
            throw AuthStoreError.keychainError(status)
        }

        let attributeItems: [[String: Any]]
        if let array = result as? [[String: Any]] {
            attributeItems = array
        } else if let single = result as? [String: Any] {
            attributeItems = [single]
        } else {
            return []
        }

        let accountKeys = attributeItems.compactMap { $0[kSecAttrAccount as String] as? String }
        return try accountKeys
            .compactMap { try load(accountKey: $0) }
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
    }

    func load(accountKey: String) throws -> StoredAuth? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw AuthStoreError.keychainError(status)
        }
        guard let data = result as? Data else {
            throw AuthStoreError.decodingFailed
        }
        return try decodeStoredAuth(from: data, decoder: JSONDecoder())
    }

    private func decodeStoredAuth(from data: Data, decoder: JSONDecoder) throws -> StoredAuth {
        if let auth = try? decoder.decode(StoredAuth.self, from: data) {
            return auth
        }
        if let base64String = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            let decodedData = Data(base64Encoded: base64String),
            let auth = try? decoder.decode(StoredAuth.self, from: decodedData)
        {
            return auth
        }
        throw AuthStoreError.decodingFailed
    }

    func delete(accountKey: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AuthStoreError.keychainError(status)
        }

        if activeAccountKeyValue() == accountKey {
            setActiveAccountKey(nil)
        }
    }

    func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AuthStoreError.keychainError(status)
        }

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
