import XCTest

class UnknownCaseEnumTests: XCTestCase {
    func testCodable() async throws {
        enum Mode: String, Codable {
            case fit
            case fill
        }

        let mode: Unknown<Mode> = .init(.fit)
        switch mode {
        case .case(.fit):
            ()
        case .case(.fill):
            ()
        case .unknown(_):
            ()
        }
    }
}

public enum Unknown<Wrapped: RawRepresentable>: RawRepresentable {
    case `case`(Wrapped)
    case unknown(Wrapped.RawValue)

    public init(_ caseValue: Wrapped) { self = .case(caseValue) }

    public init(rawValue: Wrapped.RawValue) {
        if let caseValue = Wrapped(rawValue: rawValue) {
            self = .case(caseValue)
        } else {
            self = .unknown(rawValue)
        }
    }

    public var rawValue: Wrapped.RawValue {
        switch self {
        case .case(let wrapped):
            return wrapped.rawValue
        case .unknown(let rawValue):
            return rawValue
        }
    }
}

extension Unknown: Decodable where Wrapped.RawValue: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Wrapped.RawValue.self)
        let caseValue = Wrapped.init(rawValue: rawValue)
        if let caseValue {
            self = .case(caseValue)
        } else {
            self = .unknown(rawValue)
        }
    }
}

extension Unknown: Encodable where Wrapped.RawValue: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .`case`(let caseValue):
            try container.encode(caseValue.rawValue)
        case .unknown(let rawValue):
            try container.encode(rawValue)
        }
    }
}

extension Unknown: Equatable where Wrapped: Equatable, Wrapped.RawValue: Equatable {
    public static func == (lhs: Unknown<Wrapped>, rhs: Unknown<Wrapped>) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public static func == (lhs: Unknown<Wrapped>, rhs: Wrapped) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension Unknown: Sendable where Wrapped: Sendable, Wrapped.RawValue: Sendable {}
