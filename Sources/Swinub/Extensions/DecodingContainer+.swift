import Foundation

// Override decode
public extension KeyedDecodingContainer {
    func decodeIfPresent(_ type: URL.Type, forKey key: Key) throws -> URL? {
        try? decode(type, forKey: key)
    }
}

// Fedibird以外で同じキーを使おうとしているならnilにする
public extension KeyedDecodingContainer {
    func decodeIfPresent(_ type: [EmojiReaction].Type, forKey key: Key) throws -> [EmojiReaction]? {
        try? decode(type, forKey: key)
    }
}

extension KeyedDecodingContainer {
    // ["value"]と"value"をどちらもデコードできる
    func decodeArrayOrValue<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> [T] {
        do {
            return try decode([T].self, forKey: key)
        } catch let error as DecodingError {
            if case .typeMismatch = error {
                let value = try decode(T.self, forKey: key)
                return [value]
            } else {
                throw error
            }
        }
    }
}
