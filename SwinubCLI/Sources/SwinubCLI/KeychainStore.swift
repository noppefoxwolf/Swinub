import Foundation
import Security

enum KeychainError: LocalizedError {
    case osStatus(OSStatus)
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .osStatus(let status):
            if status == errSecInteractionNotAllowed {
                return "Keychain error (\(status)): User interaction is not allowed. Your login keychain may be locked; run 'security unlock-keychain' and try again."
            }
            if let message = SecCopyErrorMessageString(status, nil) as String? {
                return "Keychain error (\(status)): \(message)"
            }
            return "Keychain error (\(status))."
        case .commandFailed(let message):
            return message
        }
    }
}

struct KeychainStore: Sendable {
    let service: String

    init(service: String) {
        self.service = service
    }

    /// Saves data for the given account.
    ///
    /// Uses `/usr/bin/security add-generic-password -T ""` so unsigned CLI rebuilds
    /// do not trigger legacy Keychain ACL interaction errors.
    func set(_ data: Data, forAccount account: String) throws {
        let payload = data.base64EncodedString()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = [
            "add-generic-password",
            "-s", service,
            "-a", account,
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
                throw KeychainError.osStatus(errSecInteractionNotAllowed)
            }
            throw KeychainError.commandFailed(
                stderrText.isEmpty
                    ? "Failed to save credentials to Keychain (exit \(process.terminationStatus))."
                    : "Failed to save credentials to Keychain: \(stderrText)"
            )
        }
    }

    func data(forAccount account: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw KeychainError.osStatus(status)
        }
        guard let rawData = result as? Data else {
            return nil
        }

        if let base64String = String(data: rawData, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            let decoded = Data(base64Encoded: base64String)
        {
            return decoded
        }
        return rawData
    }

    func allAccounts() throws -> [String] {
        // Legacy macOS Keychain rejects kSecMatchLimitAll combined with kSecReturnData (errSecParam),
        // so query attributes first and let callers fetch item data individually.
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
            throw KeychainError.osStatus(status)
        }

        let attributeItems: [[String: Any]]
        if let array = result as? [[String: Any]] {
            attributeItems = array
        } else if let single = result as? [String: Any] {
            attributeItems = [single]
        } else {
            return []
        }

        return attributeItems.compactMap { $0[kSecAttrAccount as String] as? String }
    }

    func remove(account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.osStatus(status)
        }
    }

    func removeAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.osStatus(status)
        }
    }
}
