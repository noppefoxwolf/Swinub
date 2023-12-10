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
