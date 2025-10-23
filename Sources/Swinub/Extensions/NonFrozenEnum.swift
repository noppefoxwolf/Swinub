public enum NonFrozenEnum<T>: Sendable where T: RawRepresentable & Sendable, T.RawValue: Sendable {
    case value(T)
    case unknown(T.RawValue)
}

extension NonFrozenEnum: Decodable where T: Decodable, T.RawValue: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let value = try container.decode(T.self)
            self = .value(value)
        } catch {
            let unknown = try container.decode(T.RawValue.self)
            self = .unknown(unknown)
        }
    }
}

extension NonFrozenEnum: Encodable where T: Encodable, T.RawValue: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .value(let value):
            try container.encode(value)
        case .unknown(let unknown):
            try container.encode(unknown)
        }
    }
}

extension NonFrozenEnum: Equatable where T: Equatable, T.RawValue: Equatable {
    public static func == (lhs: NonFrozenEnum, rhs: NonFrozenEnum) -> Bool {
        switch (lhs, rhs) {
        case (.value(let l), .value(let r)):
            return l == r
        case (.unknown(let l), .unknown(let r)):
            return l == r
        default:
            return false
        }
    }
}
