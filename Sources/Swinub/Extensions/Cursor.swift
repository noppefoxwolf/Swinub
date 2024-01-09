import Foundation
import RegexBuilder

public struct PrevCursor: Codable, Equatable, Sendable {
    public init(minID: String) {
        self.minID = minID
    }

    public let minID: String
}

public struct NextCursor: Codable, Equatable, Sendable {
    public init(maxID: String) {
        self.maxID = maxID
    }

    public let maxID: String
}

fileprivate enum Relation: String {
    case prev
    case next
}

public struct ResponseHeaderLinkDecoder {
    public init() {}

    public func decode(from data: Data) -> (prev: PrevCursor?, next: NextCursor?) {
        let urlReference = Reference<URL?>()
        let relReference = Reference<Relation?>()
        let regex = Regex {
            "<"
            Capture(
                as: urlReference,
                {
                    OneOrMore {
                        CharacterClass.anyOf(">").inverted
                    }
                },
                transform: { URL(string: String($0)) }
            )
            ">"
            "; "
            "rel="
            #"""#
            Capture(
                as: relReference,
                {
                    ChoiceOf {
                        Relation.next.rawValue
                        Relation.prev.rawValue
                    }
                },
                transform: { Relation(rawValue: String($0)) }
            )
            #"""#
        }

        var prevCursor: PrevCursor? = nil
        var nextCursor: NextCursor? = nil

        let text = String(data: data, encoding: .utf8)
        guard let text else {
            return (prev: nil, next: nil)
        }
        
        for match in text.matches(of: regex) {
            let url = match[urlReference]
            let components = url.map {
                URLComponents(
                    url: $0,
                    resolvingAgainstBaseURL: false
                )
            }.flatMap({ $0 })
            let rel = match[relReference]
            
            guard let components, let rel else { continue }
            switch rel {
            case .next:
                guard let maxID = components.getQueryValue(forName: "max_id") else { continue }
                nextCursor = NextCursor(maxID: maxID)
            case .prev:
                guard let minID = components.getQueryValue(forName: "min_id") else { continue }
                prevCursor = PrevCursor(minID: minID)
            }
        }
        return (prev: prevCursor, next: nextCursor)
    }
}

extension URLComponents {
    fileprivate func getQueryValue(forName name: String) -> String? {
        queryItems?.first(where: { $0.name == name })?.value
    }
}
