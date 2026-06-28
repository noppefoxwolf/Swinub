import ArgumentParser
import Foundation
import Swinub

struct ScopeList: CustomStringConvertible, ExpressibleByArgument {
    let scopes: [Scope]
    var description: String {
        scopes.map(\.rawValue).joined(separator: ",")
    }

    init(scopes: [Scope]) {
        self.scopes = scopes
    }

    init?(argument: String) {
        let values = argument.split(separator: ",").map {
            String($0).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let scopes = values.compactMap(Scope.init(rawValue:))

        guard scopes.count == values.count else {
            return nil
        }

        self.scopes = scopes.isEmpty ? [.read] : scopes
    }
}
